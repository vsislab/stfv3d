function para = learn_fisher_vector_model( para )

disp('Learn Body-Action Model ...');

loaddir = para.dir.loadSequences;
savedir = para.dir.saveFeatures;
indexes = para.indexes;
if isfield(para, 'indexValues')
	indexValues = para.indexValues;
else
	indexValues = cell(size(indexes));
end
if isfield(para, 'orientations')
	orientations = para.orientations;
else
	orientations = cell(size(indexes));
end

camProbe = para.cam.camProbe;
camGallery = para.cam.camGallery;
trainMode = para.fv.trainMode;	% 1-gallery; 2-training; 3-gallery & training
sampleRate = para.fv.sampleRate;
l_num = para.fv.l_num;
l_body = para.fv.l_body;
if para.fv.usePart_pos==1
	part_pos = para.part_pos;
	num_part = para.num_part;
elseif para.fv.usePart_pos>=2
    num_part = size(para.BBoxes{1,1},2)/4; % dpm
else
	part_pos = my_patchGen(para.window_size,...
		para.fv.h_num,para.fv.w_num,para.fv.h_overlap,para.fv.w_overlap);
	num_part = size(part_pos,2);
end

train_set = repmat(struct('data',[]), [num_part*para.fv.l_num,1]);

ldTrainingDir = [savedir '\local description'];
if ~exist(ldTrainingDir,'dir'); mkdir(ldTrainingDir); end;

ldTrainingSet = [savedir '\local description\trainingSet' para.fv.nameSet '.mat'];
if exist(ldTrainingSet, 'file') && ~para.retrain
	load(ldTrainingSet);
else

dlist = dir(loaddir);
crossIndex = para.crossIndex;
f = para.f;

disp('Extract local descriptions from training set:              ');
for d = 3:length(dlist)
	cam_id = str2double(dlist(d).name(end));
	ddlist = dir([loaddir '\' dlist(d).name]);
    ddlist = ddlist(1:min(length(ddlist),para.sampleN+2));
	for dd = 3:length(ddlist)
		per_id = str2double(ddlist(dd).name(end-2:end));
		per_idx = dd - 2;
		if (trainMode==1 && cam_id ~= camGallery) ||...
				(trainMode==2 && crossIndex(per_idx) == f) ||...
				(trainMode==3 && ~(cam_id == camGallery && crossIndex(per_idx) ~= f)) ||...
				(trainMode==4 && ~(cam_id == camProbe && crossIndex(per_idx) ~= f))
			continue;
		end
		
		if isfield(para, 'indexOmit')
			if any(para.indexOmit == per_id)
				continue;
			end
		end

		% load image sequence
		imgdir = [loaddir '\' dlist(d).name '\' ddlist(dd).name];
		imglist = dir(imgdir);
		imgs = [];
		for i = 3:length(imglist)
			img = imread([imgdir '\' imglist(i).name]);
			imgs = cat(4,imgs,img);
		end
		
		orientation = orientations{d-2,dd-2};
		
		% image preprocess
		imgsTemp = double(imgs)/255;	% 0~255 -> 0~1
		for l=1:size(imgsTemp,4)
			if strcmp(para.fv.color_mode, 'RGB')
				temp(:,:,:,l) = imgsTemp(:,:,:,l);
			elseif strcmp(para.fv.color_mode, 'RGI')
				temp(:,:,:,l) = my_rgb2rgi(imgsTemp(:,:,:,l));
			elseif strcmp(para.fv.color_mode, 'HSV')
				temp(:,:,:,l) = rgb2hsv(imgsTemp(:,:,:,l));
			end
			
			if para.fv.histeq
				for i=para.fv.histeq
					temp(:,:,i,l) = histeq(temp(:,:,i,l));
				end
			end
		end
		imgsTemp = temp;
		
		% calc local description
		index = indexes{d-2,dd-2};
		indexValue = indexValues{d-2,dd-2};
        

if para.modeLoc==0 && para.fv.usePart_pos<=1
    for j = 1:num_part
        part_yindex = part_pos(2,j):part_pos(4,j);
        part_xindex = part_pos(1,j):part_pos(3,j);
        imgsPart = imgsTemp(part_yindex,part_xindex,:,:);
        if any(j == l_body)
            local_desc = compute_ld_part(imgsPart, index, indexValue, 0, para);
            sampleIdx = randperm(length(local_desc));
            train_set((j-1)*l_num+1).data = [train_set((j-1)*l_num+1).data; ...
                local_desc(sampleIdx(1:ceil(length(local_desc)*sampleRate)),:)];
        else
            for k = 1:l_num
                local_desc = compute_ld_part(imgsPart, index, indexValue, k, para);
                sampleIdx = randperm(length(local_desc));
                train_set((j-1)*l_num+k).data = [train_set((j-1)*l_num+k).data; ...
                    local_desc(sampleIdx(1:ceil(length(local_desc)*sampleRate)),:)];
            end
        end
    end
else
    desc = compute_ld_all(imgsTemp, index, para);
    if para.fv.usePart_pos>=2
        part_poses = floor(para.BBoxes{d-2,dd-2});
        part_poses(part_poses<1) = 1;
    else
        part_poses = repmat(part_pos(:)',size(imgsTemp,4),1);
    end
    
    for j = 1:num_part
        for k = 1:l_num
            local_desc = compute_ld_all_part(desc, part_poses, index, indexValue, j, k, para);
            sampleIdx = randperm(size(local_desc,1));
            train_set((j-1)*l_num+k).data = [train_set((j-1)*l_num+k).data; ...
                local_desc(sampleIdx(1:ceil(size(local_desc,1)*sampleRate)),:)];
        end
    end
end

progress('', dd-2, length(ddlist)-2);
    end
end
fprintf('\n');

save(ldTrainingSet,'train_set','-v7.3');
end

local_desc_dims = size(train_set(1).data, 2);
std_mu = zeros(num_part*para.fv.l_num, local_desc_dims, 'single');
pc_variance = zeros(num_part*para.fv.l_num, local_desc_dims, 'single');

if para.fv.pcaCompN
	local_pca_dims = min(local_desc_dims, para.fv.pcaCompN);
else
	local_pca_dims = local_desc_dims;
end
for j = 1:num_part*para.fv.l_num
	if any(fix((j+3)/para.fv.l_num) == para.fv.l_body) && mod(j-1,para.fv.l_num)
		continue;
	end
	
	[pca_model{j}, tempData, pca_svTemp, ~, pc_variance(j,:), std_mu(j,:)] = ...
		pca(train_set(j).data, 'Centered', true, 'NumComponents', local_pca_dims);
	if para.fv.pcaCompN
		train_set(j).data = tempData;
	end
	
	pca_sv(j,:) = pca_svTemp;
	pca_remain(j,1) = sum(pca_svTemp(1:local_pca_dims))/sum(pca_svTemp);
	
	gmm_model{j} = learn_gmm_model(train_set(j).data, para);
	
	progress('Train Body-Action Units',j,num_part*para.fv.l_num);
	
end

part_prob_dims = para.fv.num_cluster;
prob_dims = part_prob_dims * num_part *para.fv.l_num;
part_feature_dims = local_pca_dims * 2 * para.fv.num_cluster *para.fv.l_num;
feature_dims = part_feature_dims * num_part;
fvpara = para.fv;
save(para.fv.fvModelFile,...
	'std_mu','pca_model','pc_variance','gmm_model'...
	,'part_prob_dims','prob_dims','part_feature_dims','feature_dims',...
	'fvpara');

if isfield(para.fv, 'fvpara')
	para.fv = rmfield(para.fv, 'fvpara');
end
para.fv.fvpara = para.fv;
para.fv.std_mu = std_mu;
para.fv.pca_model = pca_model;			% PCA dimension reduction: coeff = pca_model * (x - std_mu)
para.fv.pca_sv = pca_sv;
para.fv.pca_remain = pca_remain;
para.fv.pc_variance = pc_variance;
para.fv.gmm_model = gmm_model;
para.fv.part_prob_dims = part_prob_dims;
para.fv.prob_dims = prob_dims;
para.fv.part_feature_dims = part_feature_dims;
para.fv.feature_dims = feature_dims;

disp('Learn Body-Action Model ... Done!');
end


function gmm_optimal = learn_gmm_model(train_data, para)

options = statset('Display','off','MaxIter',para.fv.max_iter);

gmm_optimal = gmdistribution;
min_log_likelihood = inf;
for i = 1:para.fv.try_times

	gmm_try = gmdistribution.fit(train_data,para.fv.num_cluster,'Options',options,'CovType','diagonal','Regularize',1e-8);
	if gmm_try.NlogL < min_log_likelihood
		min_log_likelihood = gmm_try.NlogL;
		gmm_optimal = gmm_try;
	end
	
end

end
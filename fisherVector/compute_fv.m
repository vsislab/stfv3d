function [ features ] = compute_fv( imgs, index, indexValue, orientation, para ,fType, d, dd )
%COMPUTE_FV Summary of this function goes here
%   Detailed explanation goes here

% image preprocess
imgsTemp = double(imgs)/255;	% 0~255 -> 0~1
for l=1:size(imgsTemp,4)
	if strcmp(para.(fType).color_mode, 'RGB')
		temp(:,:,:,l) = imgsTemp(:,:,:,l);
	elseif strcmp(para.(fType).color_mode, 'RGI')
		temp(:,:,:,l) = my_rgb2rgi(imgsTemp(:,:,:,l));
	elseif strcmp(para.(fType).color_mode, 'HSV')
		temp(:,:,:,l) = rgb2hsv(imgsTemp(:,:,:,l));
	end
	
	if para.(fType).histeq
		for i=para.(fType).histeq
			temp(:,:,i,l) = histeq(temp(:,:,i,l));
		end
	end
end
imgsTemp = temp;

adaptivemode = para.adaptivemode;
% adaptivemode = 3;
l_num = para.(fType).l_num;
channels = para.(fType).channels;
threshold = para.of.indexThresholdValue;
if ~adaptivemode
	L = para.(fType).L;
	ldelta = floor(2*L/l_num);
else
	patches = para.(fType).l_all;
	patchN = patches/l_num;
end
if para.(fType).usePart_pos==1 % 1-fixed
	part_pos = para.part_pos;
	part_poses = repmat(part_pos(:)',size(imgsTemp,4),1);
elseif para.(fType).usePart_pos>=2 % 2-dpm; 3-flexible
    part_poses = floor(para.BBoxes{d-2,dd-2});
    part_poses(part_poses<1) = 1;
else % 0-grid
	part_pos = my_patchGen(para.window_size,...
		para.(fType).h_num,para.(fType).w_num,para.(fType).h_overlap,para.(fType).w_overlap);
	part_poses = repmat(part_pos(:)',size(imgsTemp,4),1);
end
num_part = size(part_poses,2)/4;

features = [];
features.feature{1} = [];
features.index = [];
features.indexEnd = [];
features.fragSign = [];
features.fragOrie = [];

desc = compute_ld_all(imgsTemp, index, para);
ii = 1;

if ~adaptivemode
	startIndex = abs(index);
else
	switch adaptivemode
		case {1, 4}	% 每个极值取视频段
			start = 1;
			startIndex = start:1:length(index)-patches;	% +1-1
		case 2	% 每个谷值取视频段
			start = (sign(index(1))+3)/2;
			startIndex = start:2:length(index)-patches;
		case 3	% 每个峰值取视频段
			start = (-sign(index(1))+3)/2;
			startIndex = start:2:length(index)-patches;
	end
end

for i = startIndex
    if ~adaptivemode
        if size(imgsTemp,4)<2*L; continue; end
		if i<=L
			imgSeq = imgsTemp(:,:,:,1:2*L);
			fragIdx = 1;
		elseif i>=size(imgsTemp,4)-L+1
			imgSeq = imgsTemp(:,:,:,end-2*L+1:end);
			fragIdx = size(imgsTemp,4)-2*L+1;
		else
			imgSeq = imgsTemp(:,:,:,i-L:i+L-1);
			fragIdx = i-L;
		end
		fragIdxEnd = fragIdx+2*L-1;
		fragSign = 1;
		
	else
		if ~isempty(indexValue)
			if indexValue(patches,i) < threshold
				continue;
			end
		end
		
		temporal = abs(index(i:i+patches));
		imgSeq = imgsTemp(:,:,:,temporal(1):temporal(end)-1);
		sizeL = temporal-temporal(1)+1;
		fragIdx = temporal(1);
		fragIdxEnd = temporal(end)-1;
		fragSign = sign(index(i));
    end
    
    feat_ok = true;
    fv_desc = [];
    if para.modeLoc==0 && para.fv.usePart_pos<=1
        
        for j = 1:num_part
            part_yindex = part_pos(2,j):part_pos(4,j);
            part_xindex = part_pos(1,j):part_pos(3,j);
            if any(j == para.(fType).l_body)
                imgSeqPart = imgSeq(part_yindex,part_xindex,channels,:);
                local_desc = my_ld_dense_sample(imgSeqPart,para);
                fv_temp = compute_one_fisher_vec(local_desc,para.fv.std_mu((j-1)*l_num+1,:),para.fv.pca_model{(j-1)*l_num+1},para.fv.gmm_model{(j-1)*l_num+1},para);
                fv_desc = [fv_desc; fv_temp];
            else
                for k = 1:l_num
                    if ~adaptivemode
                        part_zindex = (k-1)*ldelta+1 : k*ldelta;
                    else
                        zstarti = (k-1)*patchN+1;
                        zendi = k*patchN+1;
                        zstart = floor(linear_interpolation(zstarti, sizeL(floor(zstarti)), sizeL(ceil(zstarti))));
                        zend = floor(linear_interpolation(zendi, sizeL(floor(zendi)), sizeL(ceil(zendi))));
                        part_zindex = zstart:zend-1;
                    end
                    imgSeqPart = imgSeq(part_yindex,part_xindex,channels,part_zindex);
                    local_desc = my_ld_dense_sample(imgSeqPart,para);
                    fv_temp = compute_one_fisher_vec(local_desc,para.fv.std_mu((j-1)*l_num+k,:),para.fv.pca_model{(j-1)*l_num+k},para.fv.gmm_model{(j-1)*l_num+k},para);
                    % 		fv_desc((j-1)*para.fv.part_feature_dims+1:j*para.fv.part_feature_dims) = fv_temp;
                    fv_desc = [fv_desc; fv_temp];
                end
            end
        end
        
    else
        
        for j = 1:num_part
            for k = 1:l_num
                zstarti = (k-1)*patchN+1;
                zendi = k*patchN+1;
                zstart = floor(linear_interpolation(zstarti, sizeL(floor(zstarti)), sizeL(ceil(zstarti))));
                zend = floor(linear_interpolation(zendi, sizeL(floor(zendi)), sizeL(ceil(zendi))));
                
                local_desc = [];
                for jj = temporal(1)+zstart-1:temporal(1)+zend-2
                    if all(part_poses(jj,:)==1); continue; end
                    part_pos = reshape(part_poses(jj,:)',4,size(part_poses,2)/4)';
                    part_pos(part_pos(:,3)>para.window_size(2),3)=para.window_size(2);
                    part_pos(part_pos(:,4)>para.window_size(1),4)=para.window_size(1);
                    descT = desc(:,part_pos(j,2):part_pos(j,4),part_pos(j,1):part_pos(j,3),jj);
                    descT = reshape(descT, size(descT,1), numel(descT)/size(descT,1))';
                    
                    if para.modeLoc==2
                        width = part_pos(j,3)-part_pos(j,1)+1;
                        height = part_pos(j,4)-part_pos(j,2)+1;
                        frame = zend-zstart;
                        [X, Y] = meshgrid((1:width)/width, (1:height)/height);
                        Z = ones(height, width)*(jj-temporal(1)-zstart+2)/frame;
                        descT = [X(:) Y(:) Z(:) descT];
                    end
                    
                    local_desc = [local_desc; descT];
                end
                if isempty(local_desc); feat_ok = false; continue; end
                fv_temp = compute_one_fisher_vec(local_desc,para.fv.std_mu((j-1)*l_num+k,:),para.fv.pca_model{(j-1)*l_num+k},para.fv.gmm_model{(j-1)*l_num+k},para);
                fv_desc = [fv_desc; fv_temp];
            end
        end
    end
    if ~feat_ok; continue; end
	features.feature{ii} = fv_desc(:);
	features.index(ii) = fragIdx;
	features.indexEnd(ii) = fragIdxEnd;
	features.fragSign(ii) = fragSign;
	features.fragOrie(ii) = sign(mean(orientation));
% 	progress('FV', ii, length(index));
	features.hasstartIndex = true;
	ii = ii+1;
end

if ~isfield(features,'hasstartIndex')
	features.hasstartIndex = false;
end

end


function [fv, fv_prob] = compute_one_fisher_vec(local_desc, std_mu, pca, gmm, para)
% Input:
%	local_desc: input local descriptors with size [dims, height, width]
%	gmm: gaussian mixture model
% Output:
%	fv: local descriptors encoded by fisher vector
%	fv_prob: posterior of local descriptors belonging to gmm

% lk modify 2014/12/18
fvComp = para.fv.WMuSigma;

% Standardize and pca transform local descriptors
if para.fv.pcaCompN
	local_desc = bsxfun(@minus, local_desc, std_mu) * pca;
end

% Fisher Vector encoding
comp_size = gmm.NComponents;
[point_size, ~] = size(local_desc); % T: number of local features, D: dim of local features
post_prob = single(posterior(gmm, local_desc));

% post_prob = bsxfun(@rdivide, post_prob, gmm.PComponents);
% post_prob = bsxfun(@rdivide, post_prob, sum(post_prob,2));

fv_prob = transpose(mean(post_prob));

soft_assign = reshape(post_prob, [point_size, 1, comp_size]); % soft assignment of feature points to every cluster in gmm model
diff = bsxfun(@minus, local_desc, reshape(gmm.mu',1,[],comp_size));

fv = [];
if find(fvComp == 1)
	w_temp = bsxfun(@minus, post_prob, gmm.PComponents);
% 	fisher_w = bsxfun(@rdivide, sum(w_temp), sqrt(gmm.PComponents));
	fisher_w = bsxfun(@rdivide, sum(w_temp), sqrt(gmm.PComponents)) / point_size;
	fv = [fv; fisher_w(:)];
end

if find(fvComp == 2)
	mu_temp = bsxfun(@times, soft_assign, bsxfun(@rdivide, diff, sqrt(gmm.Sigma)));
	mu_norm_factor = point_size * sqrt(gmm.PComponents');
	fisher_mu = bsxfun(@rdivide, transpose(squeeze(sum(mu_temp))), mu_norm_factor);
	fv = [fv; fisher_mu(:)];
end

if find(fvComp == 3)
	sigma_temp = bsxfun(@times, soft_assign, bsxfun(@rdivide, diff.*diff, gmm.Sigma)-1);
	sigma_norm_factor = point_size * sqrt(2*gmm.PComponents');
	fisher_sigma = bsxfun(@rdivide, transpose(squeeze(sum(sigma_temp))), sigma_norm_factor);
	fv = [fv; fisher_sigma(:)];
end

% fv = [fisher_mu(:); fisher_sigma(:)]; % original fisher vector

% fv = [fisher_w(:); fisher_mu(:); fisher_sigma(:)]; % original fisher vector

% normalization
fv = sign(fv).*(abs(fv)).^0.5; % power
fv = fv/norm(fv); % L2

end
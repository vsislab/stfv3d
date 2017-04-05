function [ features, para, ft, ftInfo ] = my_1_featureExtraction_test( indexes, para )
%MY_1_FEATUREEXTRACTION_FRAG_TEST Summary of this function goes here
%   Detailed explanation goes here

loaddir = para.dir.loadSequences;
savedir = [para.dir.saveFeatures '\features'];

para.test = [];

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

ft = [];
ftInfo = struct('fraIdx',[],'fraIdxEnd',[],'fraSign',[],'fraOrie',[],...
	'perIdx',[],'camIdx',[]);

para.fv.nameFeature = para.fv.nameMode;
para.fv.fvFeatureFile = [savedir '\features' para.fv.nameFeature '.mat'];
para.ml.featureFile = [para.dir.DMLFeatures,'\features',para.fv.nameFeature,'.mat'];

if para.useml &&...
		exist(para.fv.fvFeatureFile,'file') && ...
        exist(para.ml.featureFile,'file') && ...
        ~para.retrain
	load(para.fv.fvFeatureFile,'features');
	load(para.ml.featureFile,'ft','ftInfo','ux');
	fprintf('Extract Features: Loaded!\n');
elseif ~para.useml && exist(para.fv.fvFeatureFile,'file') && ~para.retrain
	load(para.fv.fvFeatureFile,'features');
	fprintf('Extract Features: Loaded!\n');

else

[~, dataset] = fileparts(para.dir.root);
dlist = dir(loaddir);
for d = 1:length(dlist)
	if strcmp(dlist(d).name, '.') || strcmp(dlist(d).name, '..')
		continue;
	end
	if strcmp(dataset,'prid_2011')
		cam_id = int2str(abs(dlist(d).name(end))-96);
	else
		cam_id = dlist(d).name(end);
	end
	ddlist = dir([loaddir '\' dlist(d).name]);
    ddlist = ddlist(1:min(length(ddlist),para.sampleN+2));
	
	if isfield(para, 'useml') && para.useml
		dds = 1:length(ddlist);
	else
		dds = para.testPer+2;
	end
	for dd = dds
		if strcmp(ddlist(dd).name, '.') || strcmp(ddlist(dd).name, '..')
			continue;
        end
        
        if strcmp(para.dir.root(end-3:end),'-VID') || strcmp(para.dir.root(end-3:end),'2011')
            per_id = ddlist(dd).name(end-2:end);
        else
            nameList = regexp(ddlist(dd).name, '_', 'split');
            per_id = ddlist(dd).name(end-2:end);
            for i=2:length(nameList)
                if strcmpi(nameList{i}(1), 'R')
                    per_id = nameList{i}(2:end);
                    break
                end
            end
        end
        
		imgdir = [loaddir '\' dlist(d).name '\' ddlist(dd).name];

		if isfield(para, 'indexOmit')
			if any(para.indexOmit == str2double(per_id))
				continue;
			end
		end

% load image sequence
imglist = dir(imgdir);
imgs = [];
ii = 1;
for i = 1:length(imglist)
	if strcmp(imglist(i).name, '.') || strcmp(imglist(i).name, '..')
		continue;
	end
	img = imread([imgdir '\' imglist(i).name]);
	imgs = cat(4,imgs,img);
	ii = ii + 1;
end

% load sequence index
index = indexes{d-2,dd-2};
indexValue = indexValues{d-2,dd-2};
orientation = orientations{d-2,dd-2};

if para.usehog3d
	fvTemp = compute_hog3d(imgs,index,indexValue,orientation,para,'hog3d');
    fTemp.hog3d = fvTemp;
end

if para.usergb3d
	fvTemp = compute_rgb3d(imgs,index,indexValue,orientation,para,'rgb3d');
    fTemp.rgb3d = fvTemp;
end

if para.uselbp
	fvTemp = compute_lbp(imgs,index,indexValue,orientation,para,'lbp');
    fTemp.lbp = fvTemp;
end

if para.usefv
	fvTemp = compute_fv(imgs,index,indexValue,orientation,para,'fv',d,dd);
	fTemp.fv = fvTemp;
	
	if fvTemp.hasstartIndex
		para.test = [para.test; str2double(cam_id), str2double(per_id)];
	end
end

if isfield(para, 'useml') && para.useml
    ftTemp = [fvTemp.feature{:}];
    n = size(ftTemp,2);
    ft = [ft ftTemp];
    ftInfo.fraIdx = [ftInfo.fraIdx fvTemp.index];
    ftInfo.fraIdxEnd = [ftInfo.fraIdxEnd fvTemp.indexEnd];
    ftInfo.fraSign = [ftInfo.fraSign fvTemp.fragSign];
    ftInfo.fraOrie = [ftInfo.fraOrie fvTemp.fragOrie];
    ftInfo.perIdx = [ftInfo.perIdx ones(1,n)*(dd-2)];
    ftInfo.camIdx = [ftInfo.camIdx ones(1,n)*(d-2)];
end


if any(dd == para.testPer+2)
	features(str2double(cam_id), str2double(per_id)) = fTemp;
end

progress('Extract STFV3D Features',...
	(d-3)*(length(ddlist)-2)+dd-2, (length(dlist)-2)*(length(ddlist)-2));

	end
end

if isfield(para, 'useml') && para.useml
    fprintf('Features whiting and PCA process ... ');
	X = ft;
	g = normpdf(X.*0.5,para.ml.p.mu,para.ml.p.sigma);
	X = X .* g;
	[ux,u,m,uv] = applypca(X);
    fprintf('Done!\n');
end

if isfield(para, 'saveFeatures') && para.saveFeatures
	my_mkdir(savedir);
	save(para.fv.fvFeatureFile,'para','features');
	
	if isfield(para, 'useml') && para.useml
		my_mkdir(para.dir.DMLFeatures);
		save(para.ml.featureFile,'para','ft','ftInfo','ux');
	end
end

para.retrain = false;
end

if ~isfield(ftInfo,'fraScore') && isfield(para, 'useml') && para.useml
	ftInfo.fraScore = [];
	my_mkdir(para.dir.DMLFeatures);
	save(para.ml.featureFile,'para','ft','ftInfo','ux');
end

if isfield(para, 'useml') && para.useml
	ds = [];
	[ ds ] = CrossValidateViper(ds, para.ml.pair_metric_learn_algs,double(ux(1:min(size(ux,1),para.ml.p.numCoeffs),:)),ftInfo,para.ml.p,para);
	para.ml.ds = ds;
end

end


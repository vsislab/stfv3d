function [ comparisions, para ] = my_2_directlyProcess_test( features, para)

methods = para.comparision.methods;

fTypes = fieldnames(features);
for f=1:length(fTypes)
	fType = fTypes{f};

camId = [];
perId = [];
ii = 1;
for i = 1:size(features,1)
	for j = 1:size(features,2)
	if isempty(features(i,j).(fType))
		continue;
	end
	
	camId(ii) = i;
	perId(ii) = j;
	
	ii = ii+1;
	end
end
camList = unique(camId);
perList = unique(perId);

% testValues
if isfield(para, 'indexValues')
	indexValues = para.indexValues;
else
	indexValues = cell(size(para.indexes));
end

if isfield(para, 'orientations')
	orientations = para.orientations;
else
	orientations = cell(size(para.indexes));
end

perIdx = para.testPer;
if isfield(para, 'indexOmit')
	for i=1:length(para.indexOmit)
		perIdx = perIdx(perIdx ~= para.indexOmit(i));
	end
end

if isfield(para, 'time_w') && para.fv.l_num==4
	delta = para.fv.feature_dims/para.num_part/para.fv.l_num;
	wN = para.time_ww(:,2-para.time_w);
	wN = repmat(wN(:)',[delta,1]);
	wP = para.time_ww(:,2+para.time_w);
	wP = repmat(wP(:)',[delta,1]);
	para.time_wNP = [wN(:) wP(:)];
end

camProbe = para.cam.camProbe;
camGallery = para.cam.camGallery;
for i = 1:length(perList)
	fProbe = features(camProbe,perList(i)).(fType).feature;
	if isfield(features(camProbe,perList(i)).(fType),'fragSign')
		fSignProb = features(camProbe,perList(i)).(fType).fragSign;
	else
		fSignProb = [];
	end
	fScoreProb = indexValues{camProbe,perIdx(i)};
	fOrieProb = orientations{camProbe,perIdx(i)};
    
    for j = 1:length(perList)
		fGallery = features(camGallery,perList(j)).(fType).feature;
		if isfield(features(camGallery,perList(j)).(fType),'fragSign')
			fSignGallery = features(camGallery,perList(j)).(fType).fragSign;
		else
			fSignGallery = [];
		end
		fScoreGallery = indexValues{camGallery,perIdx(j)};
		fOrieGallery = orientations{camGallery,perIdx(j)};
        
        if isfield(para, 'useml') && para.useml
            if para.ml.uselfda
                diffs = para.ml.ds.lfda.dists{i,j}';
            else
                diffs = para.ml.ds.mahal.dists{i,j}';
            end
            if sign(mean(fOrieProb)) ~= sign(mean(fOrieGallery))
%                 diffs(:) = inf;
            end
		else
			diffs = my_descCompare(fGallery, fProbe, para, fSignGallery, fSignProb, fScoreProb, fScoreGallery, fOrieProb, fOrieGallery);
        end
		comparisions(i,j).(fType).diffs = diffs;
		comparisions(i,j).(fType).probePerId = perList(i);
		comparisions(i,j).(fType).probeCamId = camList(camProbe);
        comparisions(i,j).(fType).galleryPerId = perList(j);
        comparisions(i,j).(fType).galleryCamId = camList(camGallery);
        
        method = methods;
        [diff, galleryFragIdx, probeFragIdx] = my_min_differ(comparisions(i,j).(fType).diffs, method);
        subfield.(method) = ...
            struct('diff',diff,'galleryFragIdx',galleryFragIdx,'probeFragIdx',probeFragIdx);
        comparisions(i,j).(fType).comparisions = subfield;
    end
end
end

end


function [ results, maxRank1, para ] = my_3_directlyEvaluate_test( comparisions, para )

maxRank1 = [];
ii = 1;
fTypes = fieldnames(comparisions);
for fT=1:length(fTypes)
	fType = fTypes{fT};
	data_org = [comparisions(:).(fType)];
	data_org = reshape(data_org,size(comparisions));

methods = fieldnames(data_org(1,end).comparisions);

rank1Precisions=zeros(1);
rank1Details = [];
rank0Precisions=[];
rank0Details = [];

method = methods{1};
testPer = para.testPer;

if isfield(para, 'indexOmit')
    for i=1:length(para.indexOmit)
        testPer = testPer(testPer ~= para.indexOmit(i));
    end
end

diffs = inf(length(testPer));
diffProbeFragIdxes = [];
diffGalleryFragIdxes = [];
probeIdx=[];
galleryIdx=[];
probePerId=[];
galleryPerId=[];
probeFragIdx=[];
galleryFragIdx=[];
tp=0;fp=0;
cm_person=zeros(data_org(1,end).galleryPerId);
cmc=zeros(1,length(testPer));
probeIdxes=[];
galleryIdxes=[];
probePerIds=[];
galleryPerIds=[];
probeFragIdxes=[];
galleryFragIdxes=[];
for i=1:length(testPer) % probe set
    for j=1:length(testPer)	% gallery set
        diffs(i,j) = data_org(i,j).comparisions.(method).diff;
        diffProbeFragIdxes(i,j) = data_org(i,j).comparisions.(method).probeFragIdx;
        diffGalleryFragIdxes(i,j) = data_org(i,j).comparisions.(method).galleryFragIdx;
    end
    
    % rank-1
    [~, rank1idx] = min(diffs(i,:));
    probeIdx(end+1) = i;
    galleryIdx(end+1) = rank1idx;
    probePerId(end+1) = data_org(i,rank1idx).probePerId;
    galleryPerId(end+1) = data_org(i,rank1idx).galleryPerId;
    probeFragIdx(end+1) = diffProbeFragIdxes(i,rank1idx);
    galleryFragIdx(end+1) = diffGalleryFragIdxes(i,rank1idx);
    % precision
    if probePerId(end) == galleryPerId(end)
        tp = tp+1;
    else
        fp = fp+1;
    end
    % confusion matrix
    cm_person(probePerId(end),galleryPerId(end)) = cm_person(probePerId(end),galleryPerId(end))+1;
    
    % rank-0
    cmc_delta=zeros(1,length(testPer));
    [~, rank0idxes] = sort(diffs(i,:));
    rank0idx = find([data_org(i,rank0idxes).galleryPerId]==probePerId(end));
    cmc_delta(rank0idx:end)=1/length(testPer);
    cmc = cmc + cmc_delta;
    % add
    probeIdxes(:,end+1) = i;
    galleryIdxes(:,end+1) = rank0idxes;
    probePerIds(:,end+1) = [data_org(i,rank0idxes).probePerId]';
    galleryPerIds(:,end+1) = [data_org(i,rank0idxes).galleryPerId]';
    probeFragIdxes(:,end+1) = [diffProbeFragIdxes(i,rank0idxes)]';
    galleryFragIdxes(:,end+1) = [diffGalleryFragIdxes(i,rank0idxes)]';
    
    % 		progress('Evaluate Results', ii, size(data_org,1)*length(fTypes));
    ii = ii+1;
end
% rank-1
rank1Precisions = tp/(tp+fp);
rank1Details.mapping_index = [probeIdx; galleryIdx];
rank1Details.mapping_person = [probePerId; galleryPerId];
rank1Details.mapping_frag = [probeFragIdx; galleryFragIdx];
rank1Details.cm_person = cm_person;

% rank-0
rank0Precisions(1,1:length(testPer)) = cmc;
rank0Details.mapping_probeIdxes = probeIdxes;
rank0Details.mapping_galleryIdxes = galleryIdxes;
rank0Details.mapping_probePerIds = probePerIds;
rank0Details.mapping_galleryPerIds = galleryPerIds;
rank0Details.mapping_probeFragIdxes = probeFragIdxes;
rank0Details.mapping_galleryFragIdxes = galleryFragIdxes;

results.(fType).rank1Precisions = rank1Precisions;
results.(fType).rank1Details = rank1Details;
results.(fType).rank0Precisions = rank0Precisions;
results.(fType).rank0Details = rank0Details;

maxRank1 = [maxRank1; rank0Precisions(min([1 5 10 20],length(rank0Precisions)))];
end

end


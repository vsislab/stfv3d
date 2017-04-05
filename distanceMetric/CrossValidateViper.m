function [ ds, runs ] = CrossValidateViper(ds, learn_algs, X, ftInfo, params, para)
%function [ds,runs]=CrossValidateViper(ds,learn_algs,X,idxa,idxb,params)

runs = [];
c = length(ds)+1;

% split in equal-sized train and test sets
idxtrain = para.trainPer;
idxtest  = para.testPer;
camProbe = para.cam.camProbe;
camGallery = para.cam.camGallery;
if ~isfield(para,'adaptivemode')
	adaptivemode = 0;
else
	adaptivemode = para.adaptivemode;
end

negN = params.negN;

runs(end+1).perm = para.crossIndex;
runs(end).idxtrain = idxtrain;
runs(end).idxtest = idxtest;

fraSign = ftInfo.fraSign;
fraScore = ftInfo.fraScore;
perIdx = ftInfo.perIdx;
camIdx = ftInfo.camIdx;

trainIdx1 = [];
trainIdx2 = [];
trainMatches = [];
for i = unique(camIdx)
	for j = idxtrain
		for k = unique(fraSign)
			switch adaptivemode
				case 0
					trSrc = find(camIdx==i & perIdx==j);
					trTgtPos = find(camIdx~=i & perIdx==j);
					trTgtNeg = find(camIdx~=i & perIdx~=j);
				case {1 2 3 4}	% for more details
					trSrc = find(camIdx==i & perIdx==j & fraSign==k);
					trTgtPos = find(camIdx~=i & perIdx==j & fraSign==k);
					trTgtNeg = find(camIdx~=i & perIdx~=j & fraSign==k);
			end
			
			if any([isempty(trSrc) isempty(trTgtPos) isempty(trTgtNeg)])
				continue;
			end

			if 1	% test - train for all seq
				iis = 1:length(trSrc);
				jjs = 1:length(trTgtPos);
			else	% test - train for best seq
				[~, iis] = max(fraScore(trSrc));
				[~, jjs] = max(fraScore(trTgtPos));
			end
			
			for ii = iis
				for jj = jjs
					trainIdx1T = [trSrc(ii) trSrc(ii)*ones(1,negN)];
					trainIdx2T = [trTgtPos(jj)];
					for kk = 1:negN
						trainIdx2T = [trainIdx2T randFrom(trTgtNeg)];
					end
					trainMatchT = [1 zeros(1,negN)];

					trainIdx1 = [trainIdx1 trainIdx1T];
					trainIdx2 = [trainIdx2 trainIdx2T];
					trainMatches = [trainMatches trainMatchT];
				end
			end
			
		end
	end
end

% train on first half
for aC=1:length(learn_algs)
	cHandle = learn_algs{aC};
% 	fprintf('    training %s ',upper(cHandle.type));
    if strcmp(cHandle.type,'lfda'); setIndex(cHandle,perIdx); end;
	s = learnPairwise(cHandle,X,trainIdx1,trainIdx2,logical(trainMatches));
	if ~isempty(fieldnames(s))
% 		fprintf('... done in %.4fs\n',s.t);
		ds(c).(cHandle.type) = s;
	else
% 		fprintf('... not available');
	end
end

% test on second half
testIdxPrb = [];
testIdxGlr = [];
for j = idxtest
	tePrb = find(camIdx==camProbe & perIdx==j);
	teGlr = find(camIdx==camGallery & perIdx==j);
	
	testIdxPrb = [testIdxPrb tePrb];
	testIdxGlr = [testIdxGlr teGlr];
end

% figure();hold on;axis([0 25 30 150]);
names = fieldnames(ds(c));
for nameCounter=1:length(names)
% 	fprintf('    evaluating %s ',upper(names{nameCounter}));
	[ds(c).(names{nameCounter}).cmc,ds(c).(names{nameCounter}).dists] = calcMCMC(ds(c).(names{nameCounter}).M, X,testIdxPrb,testIdxGlr,ftInfo,para);
% 	fprintf('... done \n');
%     plot(ds(c).(names{nameCounter}).cmc,ds(c).(names{nameCounter}).roccolor);
end

end
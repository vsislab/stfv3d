function [ result, dists ] = calcMCMC( M, data, idxPrb, idxGlr, ftInfo, para )

testPer = para.testPer;
if ~isfield(para,'adaptivemode')
	adaptivemode = 0;
else
	adaptivemode = para.adaptivemode;
end
if isfield(para, 'orientations')
	orientations = para.orientations;
else
	orientations = cell(size(indexes));
end

perIdx = ftInfo.perIdx;
fraSign = ftInfo.fraSign;
fraOrie = ftInfo.fraOrie;
fraScore = ftInfo.fraScore;
perIdxPrb = perIdx(:,idxPrb);
perIdxGlr = perIdx(:,idxGlr);
fraSignPrb = fraSign(:,idxPrb);
fraSignGlr = fraSign(:,idxGlr);
fraOriePrb = fraOrie(:,idxPrb);
fraOrieGlr = fraOrie(:,idxGlr);
% fraScorePrb = fraScore(:,idxPrb);
% fraScoreGlr = fraScore(:,idxGlr);

distTemp = sqdist(data(:,idxPrb), data(:,idxGlr),M);
dist = inf(length(testPer));
dists = cell(length(testPer));
for i=1:length(testPer)
	for j=1:length(testPer)
		temp = distTemp(perIdxPrb==testPer(i),perIdxGlr==testPer(j));
		switch adaptivemode
			case 0
			case {1 2 3 4}	% for more details
				tempMask = fraSignPrb(perIdxPrb==testPer(i))'*fraSignGlr(perIdxGlr==testPer(j)) == 1;
				temp(~tempMask) = inf;
				
				if 1	% test - test for all seq
				else	% test - test for best seq
					testN = 1;
					tempMaskBest = zeros(size(temp));
					for k=unique(fraSign)
						tempScorePrb = fraScorePrb(perIdxPrb==testPer(i));
						tempScorePrb(fraSignPrb(perIdxPrb==testPer(i))~=k)=-inf;
						[~, iis] = sort(tempScorePrb,'descend');
						tempScoreGlr = fraScoreGlr(perIdxGlr==testPer(j));
						tempScoreGlr(fraSignGlr(perIdxGlr==testPer(j))~=k)=-inf;
						[~, jjs] = sort(tempScoreGlr,'descend');
						
						tempMaskBest(iis(1:min(end,testN)),jjs(1:min(end,testN))) = 1;
					end
					temp(~tempMaskBest) = inf;
				end
				
				% diff l & r
% 				if sign(mean(orientations{para.cam.camProbe,testPer(i)})) ~= ...
% 						sign(mean(orientations{para.cam.camGallery,testPer(j)}))
% 					temp(:) = inf;
% 				end
				tempMask = fraOriePrb(perIdxPrb==testPer(i))'*fraOrieGlr(perIdxGlr==testPer(j)) == 1;
				temp(~tempMask) = inf;
				
		end
		dists{i,j} = temp;
		
		[Y, I] = min(temp(:));
		if ~isempty(temp)
			[fraIdxPrb, fraIdxGlr] = ind2sub(size(temp), I(1));
			dist(i,j) = Y;
		end
	end
end

result = zeros(1,size(dist,2));
for pairCounter=1:size(dist,2)
    distPair = dist(pairCounter,:);  
    [tmp,idx] = sort(distPair,'ascend');
    result(idx==pairCounter) = result(idx==pairCounter) + 1;
end

tmp = 0;
for counter=1:length(result)
    result(counter) = result(counter) + tmp;
    tmp = result(counter);
end

end


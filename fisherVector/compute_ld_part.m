function [ local_desc ] = compute_ld_part( imgsTemp, index, indexValue, k, para )
%COMPUTE_FV Summary of this function goes here
%   Detailed explanation goes here

adaptivemode = para.adaptivemode;
l_num = para.fv.l_num;
channels = para.fv.channels;
threshold = para.of.indexThresholdValue;
if ~adaptivemode
	L = para.fv.L;
	ldelta = floor(2*L/l_num);
else
	patches = para.fv.l_all;    % 	patches = para.fv.L;
	patchN = patches/l_num;
end

local_desc = [];
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
	if strcmp(para.fv.sampleSeq,'median')
		if (mod(length(startIndex),2) && i ~= median(startIndex)) ||...
				(~mod(length(startIndex),2) && i ~= median(startIndex(1:end-1)))
			continue;
		end
	elseif strcmp(para.fv.sampleSeq,'double')
		if (mod(length(startIndex),2) ...
				&& i ~= median(startIndex) && i ~= median(startIndex(1:end-2))) ||...
				(~mod(length(startIndex),2) ...
				&& i ~= median(startIndex(1:end-1)) && i ~= median(startIndex(1:end-3)))
			continue;
		end
	end
	
	if ~adaptivemode
		if i<=L
			imgSeq = imgsTemp(:,:,:,1:2*L);
		elseif i>=size(imgsTemp,4)-L+1
			imgSeq = imgsTemp(:,:,:,end-2*L+1:end);
		else
			imgSeq = imgsTemp(:,:,:,i-L:i+L-1);
		end
		
		if ~k
			imgSeq = imgSeq(:,:,channels,:);
		else
			imgSeq = imgSeq(:,:,channels,(k-1)*ldelta+1 : k*ldelta);
		end
		
	else
		if ~isempty(indexValue)
			if indexValue(patches,i) < threshold
				continue;
			end
		end
		
		temporal = abs(index(i:i+patches));
		imgSeq = imgsTemp(:,:,:,temporal(1):temporal(end)-1);
		sizeL = temporal-temporal(1)+1;
		if ~k
			imgSeq = imgSeq(:,:,channels,:);
		else
			zstarti = (k-1)*patchN+1;
			zendi = k*patchN+1;
			zstart = floor(linear_interpolation(zstarti, sizeL(floor(zstarti)), sizeL(ceil(zstarti))));
			zend = floor(linear_interpolation(zendi, sizeL(floor(zendi)), sizeL(ceil(zendi))));
			imgSeq = imgSeq(:,:,channels,zstart:zend-1);
		end
	end
	
	descPart = my_ld_dense_sample(imgSeq,para);
	local_desc =  [local_desc; descPart];
end

end


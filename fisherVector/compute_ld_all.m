function [ desc ] = compute_ld_all( imgsTemp, index, para )
%COMPUTE_FV Summary of this function goes here
%   Detailed explanation goes here

% adaptivemode = para.adaptivemode;
adaptivemode = 3;   % for-test adaptivemode = 3
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
    for k = 1:l_num
        temporal = abs(index(i:i+patches));
        imgSeq = imgsTemp(:,:,:,temporal(1):temporal(end)-1);
        sizeL = temporal-temporal(1)+1;
        
        zstarti = (k-1)*patchN+1;
        zendi = k*patchN+1;
        zstart = floor(linear_interpolation(zstarti, sizeL(floor(zstarti)), sizeL(ceil(zstarti))));
        zend = floor(linear_interpolation(zendi, sizeL(floor(zendi)), sizeL(ceil(zendi))));
        imgSeq = imgSeq(:,:,channels,zstart:zend-1);
        
        descPart = my_ld_dense_sample(imgSeq,para);
        local_desc =  [local_desc; descPart];
    end
end

desc = [];
if ~isempty(startIndex)
    descT = local_desc';
    descT_l = size(descT,2)/size(imgSeq,1)/size(imgSeq,2);
    descT = reshape(descT,size(descT,1),size(imgSeq,1),size(imgSeq,2),descT_l);
    
    desc = zeros([size(descT(:,:,:,1)),size(imgsTemp,4)]);
    desc(:,:,:,abs(index(startIndex(1))):abs(index(startIndex(1)))+descT_l-1) = descT;
end

end


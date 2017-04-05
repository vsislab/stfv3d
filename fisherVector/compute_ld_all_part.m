function [ local_desc ] = compute_ld_all_part( desc, part_poses, index, indexValue, j, k, para )
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
    
    if ~isempty(indexValue)
        if indexValue(patches,i) < threshold
            continue;
        end
    end
    
    temporal = abs(index(i:i+patches));
    sizeL = temporal-temporal(1)+1;
    if ~k
        zstart = temporal(1);
        zend = temporal(end)-1;
    else
        zstarti = (k-1)*patchN+1;
        zendi = k*patchN+1;
        zstart = floor(linear_interpolation(zstarti, sizeL(floor(zstarti)), sizeL(ceil(zstarti))));
        zend = floor(linear_interpolation(zendi, sizeL(floor(zendi)), sizeL(ceil(zendi))));
    end
    
    descTemp = [];
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
        
        descTemp = [descTemp; descT];
    end
	local_desc =  [local_desc; descTemp];
end

end


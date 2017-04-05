function [ cuboid_descriptor, descriptor_num, subs ] = my_lbp_dense_sample( cuboid,...
	para, hNum, wNum, lNum, hOlp, wOlp, lOlp)
%   sigma and tau refer to spatial and temporal cell sizes respectivly
[seheight,sewidth,selength] = size(cuboid);

% for LBP
RotateIndex = para.lbp.RotateIndex;
TInterval = para.lbp.TInterval;
TimeLength = para.lbp.TimeLength;
BorderLength = para.lbp.BorderLength;
bBilinearInterpolation = para.lbp.bBilinearInterpolation;
Type = para.lbp.Type;	% 'VLBP' or 'LBPTOP'

% for 'VLBP' only
FRadius = para.lbp.FRadius;
NeighborPointsV = para.lbp.NeighborPointsV;

% for 'LBPTOP' only
FxRadius = para.lbp.FxRadius;
FyRadius = para.lbp.FyRadius;
Bincount = para.lbp.Bincount;	% 59 or 0
NeighborPointsL = para.lbp.NeighborPointsL;
Code = para.lbp.Code;

height = floor(seheight/((1-hOlp)*hNum+hOlp));
width = floor(sewidth/((1-wOlp)*wNum+wOlp));
length = floor(selength/((1-lOlp)*lNum+lOlp));
hdelta = floor(height*(1-hOlp));
wdelta = floor(width*(1-wOlp));
ldelta = floor(length*(1-lOlp));
tt=1;
for x=1:hNum
    for y=1:wNum
        for t=1:lNum
            block = cuboid((x-1)*hdelta+1:(x-1)*hdelta+height,...
                (y-1)*wdelta+1:(y-1)*wdelta+width,...
				(t-1)*ldelta+1:(t-1)*ldelta+length);
			if strcmp(Type, 'VLBP')
				cuboid_descriptor(:,tt) = my_RIVLBP(block, TInterval, FRadius, NeighborPointsV, BorderLength, TimeLength, RotateIndex, bBilinearInterpolation);
			elseif strcmp(Type, 'LBPTOP')
				cuboid_descriptor(:,tt) = my_LBPTOP(block, FxRadius, FyRadius, TInterval, NeighborPointsL, TimeLength, BorderLength, bBilinearInterpolation, Bincount, Code);
			end
            subs(tt,:)=[x,y,t];
            tt = tt+1;
        end
    end
end
descriptor_num = tt-1;

end


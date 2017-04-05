function [ cuboid_descriptor, descriptor_num, subs ] = my_hog3d_dense_sample( cuboid, ...
    hNum, wNum, lNum, hOlp, wOlp, lOlp)
%   sigma and tau refer to spatial and temporal cell sizes respectivly
[seheight,sewidth,selength] = size(cuboid);
% cuboid=integral3d(cuboid);
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
            cuboid_descriptor(:,tt) = hog3d_block(block,6);
            subs(tt,:)=[x,y,t];
            tt = tt+1;
        end
    end
end
descriptor_num = tt-1;

end


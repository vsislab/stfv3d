function [ cuboid_descriptor, descriptor_num, subs ] = hog3d_dense_sample( cuboid, ...
    heights, widths, lengths)
%   sigma and tau refer to spatial and temporal cell sizes respectivly
[seheight,sewidth,selength] = size(cuboid);
% cuboid=integral3d(cuboid);
height = (seheight-mod(seheight,heights))/heights;
width = (sewidth-mod(sewidth,widths))/widths;
length = (selength-mod(selength,lengths))/lengths;
tt=1;
for x=1:height
    for y=1:width
        for t=1:length
            block = cuboid((x-1)*heights+1:(x-1)*heights+heights,...
                (y-1)*widths+1:(y-1)*widths+widths,(t-1)*lengths+1:...
                (t-1)*lengths+lengths);
            cuboid_descriptor(tt,:) = hog3d_block(block,6);
            subs(tt,:)=[x,y,t];
            tt = tt+1;
        end
    end
end
descriptor_num = tt-1;

end


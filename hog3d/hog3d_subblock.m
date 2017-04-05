function [ histogram_subblock ] = hog3d_subblock( subblock, bin_num )
[l,m,n] = size(subblock);
[meangradientX,meangradientY,meangradientT]=gradient(subblock);
cell_number=0;
hist_cell=zeros(l*m*n,bin_num);
for i=1:l
    for j=1:m
        for k=1:n
            cell_number=cell_number+1;
            hist_cell(cell_number,:) ...
                = hog3d_cell(meangradientX(i,j,k),meangradientY(i,j,k),meangradientT(i,j,k), bin_num);
        end
    end
end
histogram_subblock = sum(hist_cell)./cell_number;
histogram_subblock = histogram_subblock.*8;
end


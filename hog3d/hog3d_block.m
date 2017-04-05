function [ block_descriptor ] = hog3d_block( block, bin_num )
% bin_num can only be 6 or 10
if size(size(block),2)>3; block = squeeze(block); end;   %
[seheight,sewidth,datalength]=size(block);
height = floor(seheight/2);
width = floor(sewidth/2);
length = floor(datalength/2);
cell_1 = block(1:height,1:width,1:length);
cell_2 = block(1:height,1:width,1+length:datalength);
cell_3 = block(1:height,1+width:sewidth,1:length);
cell_4 = block(1:height,1+width:sewidth,1+length:datalength);
cell_5 = block(1+height:seheight,1:width,1:length);
cell_6 = block(1+height:seheight,1:width,1+length:datalength);
cell_7 = block(1+height:seheight,1+width:sewidth,1:length);
cell_8 = block(1+height:seheight,1+width:sewidth,1+length:datalength);

hist_1 = hog3d_subblock_fast(cell_1, bin_num);
hist_2 = hog3d_subblock_fast(cell_2, bin_num);
hist_3 = hog3d_subblock_fast(cell_3, bin_num);
hist_4 = hog3d_subblock_fast(cell_4, bin_num);
hist_5 = hog3d_subblock_fast(cell_5, bin_num);
hist_6 = hog3d_subblock_fast(cell_6, bin_num);
hist_7 = hog3d_subblock_fast(cell_7, bin_num);
hist_8 = hog3d_subblock_fast(cell_8, bin_num);

block_descriptor = [hist_1,hist_2,hist_3,hist_4,hist_5...
    ,hist_6,hist_7,hist_8];
end


function [ imgOut ] = my_rgb2rgi( imgIn )
%MY_RGB2RGI Summary of this function goes here
%   Detailed explanation goes here

r = imgIn(:,:,1);
g = imgIn(:,:,2);
b = imgIn(:,:,3);
m = r+g+b + 1e-5;

imgOut(:,:,1) = r./m;
imgOut(:,:,2) = g./m;
imgOut(:,:,3) = m/3;


end


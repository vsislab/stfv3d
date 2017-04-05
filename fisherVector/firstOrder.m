function [ d ] = firstOrder( interval )
%FIRSTORDER Summary of this function goes here
%   Detailed explanation goes here

d = zeros(1, interval*2 + 1);
d(1) = -1;
d(end) = 1;

end


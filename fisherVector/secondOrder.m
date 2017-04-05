function [ dd ] = secondOrder( interval )
%SECONDORDER Summary of this function goes here
%   Detailed explanation goes here

dd = zeros(1, interval*2 + 1);
dd(1) = -1;
dd(end) = -1;
dd(interval + 1) = 2;

end


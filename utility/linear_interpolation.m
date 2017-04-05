function [ y ] = linear_interpolation( x, y1, y2 )
%LINEAR_INTERPOLATION Summary of this function goes here
%   Detailed explanation goes here

u = x-floor(x);
y = y1*(1-u) + y2*u;

end


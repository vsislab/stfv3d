function [ Y, I ] = randFrom( A )
%RANDFROM Summary of this function goes here
%   Detailed explanation goes here
I = randi(numel(A));
Y = A(I);

end


function [ux,u,m,uv] = applypca(X)
%APPLYPCA Summary of this function goes here
%   Detailed explanation goes here

[uv,u,m] = pca(X');
ux = uv'*X;

end


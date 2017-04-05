function [ dirname ] = setdir( dirname )
%SETDIR Summary of this function goes here
%   Detailed explanation goes here

if ~exist(dirname,'dir')
	mkdir(dirname)
end

end


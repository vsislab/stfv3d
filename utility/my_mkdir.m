function [ output_args ] = my_mkdir( dirname )
%MY_MKDIR Summary of this function goes here
%   Detailed explanation goes here

if ~exist(dirname,'dir')
	mkdir(dirname);
end

end


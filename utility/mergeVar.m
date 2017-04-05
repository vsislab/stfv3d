function [ para ] = mergeVar( para, vars )
%MERGEVAR Summary of this function goes here
%   Detailed explanation goes here

fNames = fieldnames(vars);
for f=1:length(fNames)
	fname = fNames{f};
	para.(fname) = vars.(fname);
	
end

end


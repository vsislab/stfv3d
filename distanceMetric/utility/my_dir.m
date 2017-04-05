function [ dirlist, dirnamelist, foldernamelist, filenamelist ] = my_dir( loaddir )
%MY_DIR Summary of this function goes here
%   Detailed explanation goes here

% loaddir = 'D:\Liukan\vs2010\work\201501\VideoProcess11';

listTemp = dir(loaddir);
dirlist = cell(0);
dirnamelist = cell(0);
foldernamelist = cell(0);
filenamelist = cell(0);
for i=1:length(listTemp)
	if strcmp(listTemp(i).name, '.') || strcmp(listTemp(i).name, '..')
		continue;
	end
	
	dirnamelist{end+1} = listTemp(i).name;
	dirlist{end+1} = [loaddir '\' dirnamelist{end}];
	
	if listTemp(i).isdir
		foldernamelist{end+1} = listTemp(i).name;
	else
		filenamelist{end+1} = listTemp(i).name;
	end

end

end


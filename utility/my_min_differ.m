function [differ, row, column] = my_min_differ( differs, method )

% differs = differs';
if isempty(differs)
	differ = inf;
	row = 1;
	column = 1;
	return;
end

if nargin ==1
	differ = min(min(differs));
else
	switch method
		case 'min'
			differ = min(differs(:));
		case 'sum_min'
			differ = (sum(min(differs,[],1))+sum(min(differs,[],2)))/sum(size(differs));
		case 'median'
			differ = median(differs(:));
		case 'mean'
			differ = mean(differs(:));
		case 'max'
			differ = max(differs(:));
		case 'diagMin'
			differ = min(diag(differs));
		case 'diagMedian'
			differ = median(diag(differs));
		case 'diagMean'
			differ = mean(diag(differs));
		case 'diagMax'
			differ = max(diag(differs));
		case 'minMin'
			differ = min(min(differs));
		case 'medianMedian'
			differ = median(median(differs));
		case 'minMedian'
			differ = median(min(differs));
		case 'medianMin'
			differ = min(median(differs));
	end
end

% differs = differs';
[~,index]=sort(abs(differs(:) - differ));
% [rows, columns] = find(differs == differs(index(1)));
% row = rows(1); column = columns(1);
[row, column] = ind2sub(size(differs),index(1));

end


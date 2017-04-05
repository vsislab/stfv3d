function [ values, values2, values3, values4 ] = fun_3_ofValues(index, E_g_filt, E_f_filt, maxR, indexV)
%FUN_3_OFVALUE Summary of this function goes here
%   Detailed explanation goes here

indexabs = abs(index);
indexVabs = abs(indexV);

values = [];
values2 = [];
values3 = [];
values4 = [];

for j = 1:length(indexabs)-1
for i = 1:length(indexabs)-j
	% 拟合-拟合/内积
	frams = indexabs(i):indexabs(i+j);
	E_g_temp = E_g_filt(frams) - mean(E_g_filt(frams));
	E_f_temp = E_f_filt(frams) - mean(E_f_filt(frams));
	values(j,i) = E_g_temp' * E_f_temp / (sum(E_g_temp.^2) * sum(E_f_temp.^2)).^0.5;
	if mean(E_g_filt(frams)) > median(E_g_filt)*maxR
		values(j,i) = -1;
	end
	
	% 拟合-滤波/距离
	frams2 = indexVabs(i):indexVabs(i+j);
	temp2 = E_g_filt(frams2);
	E_g_temp2 = interp1(0:1/(length(frams2)-1):1,temp2,0:1/(length(frams)-1):1)';
	E_f_temp2 = E_f_filt(frams);
	values2(j,i) = -sum((E_f_temp2-E_g_temp2).^2).^0.5;
	
	% 拟合-滤波/内积
	E_g_temp3 = E_g_temp2-mean(E_g_temp2);
	E_f_temp3 = E_f_temp;
	values3(j,i) = E_g_temp3' * E_f_temp3 / (sum(E_g_temp3.^2) * sum(E_f_temp3.^2)).^0.5;
	
	% 拟合-拟合/距离
	E_g_temp4 = E_g_filt(frams);
	E_f_temp4 = E_f_filt(frams);
	values4(j,i) = -sum((E_f_temp4-E_g_temp4).^2).^0.5;
end

for i = length(indexabs)-j+1:length(indexabs)-1
	values(j,i) = -inf;
	values2(j,i) = -inf;
	values3(j,i) = -inf;
	values4(j,i) = -inf;
end

end
end


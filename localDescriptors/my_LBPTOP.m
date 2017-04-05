function Histogram = my_LBPTOP(VolData, FxRadius, FyRadius, TInterval, NeighborPoints, TimeLength, BorderLength, bBilinearInterpolation, Bincount, Code)
%  This function is to compute the LBP-TOP features for a video sequence
%  Reference:
%  Guoying Zhao, Matti Pietikainen, "Dynamic texture recognition using local binary patterns
%  with an application to facial expressions," IEEE Transactions on Pattern Analysis and Machine
%  Intelligence, 2007, 29(6):915-928.
%
%   Copyright 2009 by Guoying Zhao & Matti Pietikainen
%   Matlab version was Created by Xiaohua Huang
%  If you have any problem, please feel free to contact guoying zhao or Xiaohua Huang.
% huang.xiaohua@ee.oulu.fi
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function: Running this funciton each time to compute the LBP-TOP distribution of one video sequence.
%
%  Inputs:
%
%  "VolData" keeps the grey level of all the pixels in sequences with [height][width][Length];
%       please note, all the images in one sequnces should have same size (height and weight).
%       But they don't have to be same for different sequences.
%
%  "FxRadius", "FyRadius" and "TInterval" are the radii parameter along X, Y and T axis; They can be 1, 2, 3 and 4. "1" and "3" are recommended.
%  Pay attention to "TInterval". "TInterval * 2 + 1" should be smaller than the length of the input sequence "Length". For example, if one sequence includes seven frames, and you set TInterval to three, only the pixels in the frame 4 would be considered as central pixel and computed to get the LBP-TOP feature.
%
%
%  "NeighborPoints" is the number of the neighboring points
%      in XY plane, XT plane and YT plane; They can be 4, 8, 16 and 24. "8"
%      is a good option. For example, NeighborPoints = [8 8 8];
%
%  "TimeLength" and "BoderLength" are the parameters for bodering parts in time and space which would not
%      be computed for features. Usually they are same to TInterval and the bigger one of "FxRadius" and "FyRadius";
%
%  "bBilinearInterpolation": if use bilinear interpolation for computing a neighboring point in a circle: 1 (yes), 0 (no).
%
%  "Bincount": For example, if XYNeighborPoints = XTNeighborPoints = YTNeighborPoints = 8, you can set "Bincount" as "0" if you want to use basic LBP, or set "Bincount" as 59 if using uniform pattern of LBP,
%              If the number of Neighboring points is different than 8, you need to change it accordingly as well as change the above "Code".
%  "Code": only when Bincount is 59, uniform code is used.
%  Output:
%
%  "Histogram": keeps LBP-TOP distribution of all the pixels in the current frame with [3][dim];
%      here, "3" deote the three planes of LBP-TOP, i.e., XY, XZ and YZ planes.
%      Each value of Histogram[i][j] is between [0,1]

%%
[height width Length] = size(VolData);

XYNeighborPoints = NeighborPoints(1);
XTNeighborPoints = NeighborPoints(2);
YTNeighborPoints = NeighborPoints(3);

if (Bincount == 0)
    % normal code
    nDim = 2^(YTNeighborPoints);
    Histogram = zeros(3, nDim);
else
    % uniform code
    Histogram = zeros(3, Bincount); % Bincount = 59;
end

if (bBilinearInterpolation == 0)
	y1 = BorderLength + 1;
	y2 = height - BorderLength;
	x1 = BorderLength + 1;
	x2 = width - BorderLength;
	z1 = TimeLength + 1;
	z2 = Length - TimeLength;
	CenterVals = VolData(y1:y2, x1:x2, z1:z2);
	
	%% In XY plane
	BasicLBP = zeros(size(CenterVals));
	FeaBin = 0;
	for p = 0 : XYNeighborPoints - 1
		X = floor((x1:x2) + FxRadius * cos((2 * pi * p) / XYNeighborPoints) + 0.5);
		Y = floor((y1:y2) - FyRadius * sin((2 * pi * p) / XYNeighborPoints) + 0.5);
		CurrentVals = VolData(Y, X, z1:z2);
		BasicLBP = BasicLBP + (CurrentVals >= CenterVals) * 2^FeaBin;
		FeaBin = FeaBin + 1;
	end
	temp = hist(BasicLBP(:), 0:2^NeighborPoints(1)-1);
	if Bincount == 0
		Histogram(1,:) = temp;
	else
		for i = 1:Bincount
			Histogram(1,i) = sum(temp(Code(:,2)==i-1));
		end
	end
	
	%% In XT plane
	BasicLBP = zeros(size(CenterVals));
	FeaBin = 0;
	for p = 0 : XTNeighborPoints - 1
		X = floor((x1:x2) + FxRadius * cos((2 * pi * p) / XTNeighborPoints) + 0.5);
		Z = floor((z1:z2) + TInterval * sin((2 * pi * p) / XTNeighborPoints) + 0.5);
		CurrentVals = VolData(y1:y2, X, Z);
		BasicLBP = BasicLBP + (CurrentVals >= CenterVals) * 2^FeaBin;
		FeaBin = FeaBin + 1;
	end
	temp = hist(BasicLBP(:), 0:2^NeighborPoints(2)-1);
	if Bincount == 0
		Histogram(2,:) = temp;
	else
		for i = 1:Bincount
			Histogram(2,i) = sum(temp(Code(:,2)==i-1));
		end
	end
	
	%% In YT plane
	BasicLBP = zeros(size(CenterVals));
	FeaBin = 0;
	for p = 0 : YTNeighborPoints - 1
		Y = floor((y1:y2) - FyRadius * sin((2 * pi * p) / YTNeighborPoints) + 0.5);
		Z = floor((z1:z2) + TInterval * cos((2 * pi * p) / YTNeighborPoints) + 0.5);
		CurrentVals = VolData(Y, x1:x2, Z);
		BasicLBP = BasicLBP + (CurrentVals >= CenterVals) * 2^FeaBin;
		FeaBin = FeaBin + 1;
	end
	temp = hist(BasicLBP(:), 0:2^NeighborPoints(3)-1);
	if Bincount == 0
		Histogram(3,:) = temp;
	else
		for i = 1:Bincount
			Histogram(3,i) = sum(temp(Code(:,2)==i-1));
		end
	end

else % bilinear interpolation
	
	y1 = BorderLength + 1;
	y2 = height - BorderLength;
	x1 = BorderLength + 1;
	x2 = width - BorderLength;
	z1 = TimeLength + 1;
	z2 = Length - TimeLength;
	CenterVals = VolData(y1:y2, x1:x2, z1:z2);
	
	%% In XY plane
	BasicLBP = zeros(size(CenterVals));
	FeaBin = 0;
	for p = 0 : XYNeighborPoints - 1
		dx = single(0 + FxRadius * cos((2 * pi * p) / XYNeighborPoints));
		dy = single(0 - FyRadius * sin((2 * pi * p) / XYNeighborPoints));
		
		u = dx - floor(dx);
		v = dy - floor(dy);
		X = (x1:x2) + dx;
		Y = (y1:y2) + dy;
		ltx = floor(X);
		lty = floor(Y);
		lbx = floor(X);
		lby = ceil(Y);
		rtx = ceil(X);
		rty = floor(Y);
		rbx = ceil(X);
		rby = ceil(Y);
		
		CurrentVals = floor(VolData(lty, ltx, z1:z2) * (1 - u) * (1 - v) + VolData(lby, lbx, z1:z2) * (1 - u) * v + VolData(rty, rtx, z1:z2) * u * (1 - v) + VolData(rby, rbx, z1:z2) * u * v);
		
		BasicLBP = BasicLBP + (CurrentVals >= CenterVals) * 2^FeaBin;
		FeaBin = FeaBin + 1;
	end
	temp = hist(BasicLBP(:), 0:2^NeighborPoints(1)-1);
	if Bincount == 0
		Histogram(1,:) = temp;
	else
		for i = 1:Bincount
			Histogram(1,i) = sum(temp(Code(:,2)==i-1));
		end
	end
	
	%% In XT plane
	BasicLBP = zeros(size(CenterVals));
	FeaBin = 0;
	for p = 0 : XTNeighborPoints - 1
		dx = single(0 + FxRadius * cos((2 * pi * p) / XTNeighborPoints));
		dz = single(0 + TInterval * sin((2 * pi * p) / XTNeighborPoints));
		
		u = dx - floor(dx);
		v = dz - floor(dz);
		X = (x1:x2) + dx;
		Z = (z1:z2) + dz;
		ltx = floor(X);
		lty = floor(Z);
		lbx = floor(X);
		lby = ceil(Z);
		rtx = ceil(X);
		rty = floor(Z);
		rbx = ceil(X);
		rby = ceil(Z);
		
		CurrentVals = floor(VolData(y1:y2, ltx, lty) * (1 - u) * (1 - v) + VolData(y1:y2, lbx, lby) * (1 - u) * v + VolData(y1:y2, rtx, rty) * u * (1 - v) + VolData(y1:y2, rbx, rby) * u * v);
		
		BasicLBP = BasicLBP + (CurrentVals >= CenterVals) * 2^FeaBin;
		FeaBin = FeaBin + 1;
	end
	temp = hist(BasicLBP(:), 0:2^NeighborPoints(2)-1);
	if Bincount == 0
		Histogram(2,:) = temp;
	else
		for i = 1:Bincount
			Histogram(2,i) = sum(temp(Code(:,2)==i-1));
		end
	end
	
	%% In YT plane
	BasicLBP = zeros(size(CenterVals));
	FeaBin = 0;
	for p = 0 : YTNeighborPoints - 1
		dy = single(0 - FyRadius * sin((2 * pi * p) / YTNeighborPoints));
		dz = single(0 + TInterval * cos((2 * pi * p) / YTNeighborPoints));
		
		u = dy - floor(dy);
		v = dz - floor(dz);
		Y = (y1:y2) + dy;
		Z = (z1:z2) + dz;
		ltx = floor(Y);
		lty = floor(Z);
		lbx = floor(Y);
		lby = ceil(Z);
		rtx = ceil(Y);
		rty = floor(Z);
		rbx = ceil(Y);
		rby = ceil(Z);
		
		CurrentVals = floor(VolData(ltx, x1:x2, lty) * (1 - u) * (1 - v) + VolData(lbx, x1:x2, lby) * (1 - u) * v + VolData(rtx, x1:x2, rty) * u * (1 - v) + VolData(rbx, x1:x2, rby) * u * v);
		
		BasicLBP = BasicLBP + (CurrentVals >= CenterVals) * 2^FeaBin;
		FeaBin = FeaBin + 1;
	end
	temp = hist(BasicLBP(:), 0:2^NeighborPoints(3)-1);
	if Bincount == 0
		Histogram(3,:) = temp;
	else
		for i = 1:Bincount
			Histogram(3,i) = sum(temp(Code(:,2)==i-1));
		end
	end
end

% my edit - 2014/12/12
Histogram = Histogram';
Histogram = Histogram(:);
Histogram = Histogram./sum(Histogram);

% %% normalization
% for j = 1 : 3
% %     Histogram(j, :) = Histogram(j, :)./sum(Histogram(j, :));
% end
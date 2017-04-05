function local_desc = my_ld_dense_sample(imgSeq, para)

convMode = para.fv.convMode;
inteX = para.fv.convInteX;	% conv interval on x
inteY = para.fv.convInteY;	% conv interval on y
inteZ = para.fv.convInteZ;	% conv interval on z
Ivalues = para.fv.Ivalues;	% output of local_desc

% d = [-1 0 1];
% dd = [-1 2 -1];
dx = firstOrder(inteX); ddx = secondOrder(inteX);
dy = firstOrder(inteY); ddy = secondOrder(inteY);
dz = firstOrder(inteZ); ddz = secondOrder(inteZ);
imgSeq = double(imgSeq);
[height, width, channel, frame] = size(imgSeq);
tempSeq = permute(imgSeq,[1,2,4,3]);

for i = 1:channel
	temp = tempSeq(:,:,:,i);
	I(:,i) = temp(:);
	
	y_temp = reshape(temp, height, width*frame);
	Iy_temp = imfilter(y_temp,dy',convMode);
% 	Iy_temp0 = imfilter(y_temp,dy',0);
% 	Iy_temp1 = imfilter(y_temp,dy',convMode);
% 	Iy_temp2 = imfilter(y_temp,dy','symmetric');
% 	Iy_temp3 = imfilter(y_temp,dy','replicate');
% 	Iy_temp4 = imfilter(y_temp,dy','circular');
	Iy(:,i) = Iy_temp(:);
	Iyy_temp = imfilter(y_temp,ddy',convMode);
	Iyy(:,i) = Iyy_temp(:);
	
	x_temp = reshape(permute(temp,[2,1,3]), width, height*frame);
	Ix_temp = ipermute(reshape(imfilter(x_temp,dx',convMode),width,height,frame), [2,1,3]);
	Ix(:,i) = Ix_temp(:);
	Ixx_temp = ipermute(reshape(imfilter(x_temp,ddx',convMode),width,height,frame), [2,1,3]);
	Ixx(:,i) = Ixx_temp(:);
	
	z_temp = reshape(permute(temp,[3,2,1]), frame, width*height);
	Iz_temp = ipermute(reshape(imfilter(z_temp,dz',convMode),frame,width,height), [3,2,1]);
	Iz(:,i) = Iz_temp(:);
	
	Izz_temp = ipermute(reshape(imfilter(z_temp,ddz',convMode),frame,width,height), [3,2,1]);
	Izz(:,i) = Izz_temp(:);
	
end

[X, Y, Z] = meshgrid((1:width)/width, (1:height)/height, (1:frame)/frame);

if para.modeLoc<=1
    local_desc = [X(:), Y(:), Z(:)];
else
    local_desc = [];
end

if any(Ivalues == 0)
	local_desc = [local_desc, I];
end
if any(Ivalues == 1)
	local_desc = [local_desc, Ix, Iy, Iz];
end
if any(Ivalues == 2)
	local_desc = [local_desc, Ixx, Iyy, Izz];
end

local_desc = double(local_desc);
end


% function local_desc = compute_local_desc(img)
% 
% d = [-1 0 1];
% dd = [-1 2 -1];
% dI = double(img);
% Ix = conv2(dI, d, 'same');
% Iy = conv2(dI, d', 'same');
% Ixx = conv2(dI, dd, 'same');
% Iyy = conv2(dI, dd', 'same');
% [height, width] = size(img);
% [X, Y] = meshgrid((1:width)/width, (1:height)/height);
% 
% local_desc = [X(:), Y(:), img(:), Ix(:), Iy(:), Ixx(:), Iyy(:)];
% 
% end

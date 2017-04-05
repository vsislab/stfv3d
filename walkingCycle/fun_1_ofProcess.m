function [ E, vxMean ] = fun_1_ofProcess( imgs, para )
%FUN_OFPROCESS Summary of this function goes here
%   Detailed explanation goes here

% process
if para.useflow && exist(para.files.EFile, 'file')
	load(para.files.EFile);
elseif para.useflow
	alpha = para.of.alpha;
	ratio = para.of.ratio;
	minWidth = para.of.minWidth;
	nOuterFPIterations = para.of.nOuterFPIterations;
	nInnerFPIterations = para.of.nInnerFPIterations;
	nSORIterations = para.of.nSORIterations;
	flowPara = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
	
	mode = para.of.mode;
	color = para.of.color;
	channels = para.of.channels;
	
	imgsTemp = double(imgs)/255;	% 0~255 -> 0~1
	for l=1:size(imgsTemp,4)
		if strcmp(color, 'RGB')
			temp(:,:,:,l) = imgsTemp(:,:,:,l);
		elseif strcmp(color, 'HSV')
			temp(:,:,:,l) = rgb2hsv(imgsTemp(:,:,:,l));
		end
		
% 		if para.fv.histeq
% 			for i=para.fv.histeq
% 				temp(:,:,i,l) = histeq(temp(:,:,i,l));
% 			end
% 		end
	end
	imgs = temp;
			
	
	E = [];		% flow energy
	vxMean = [];
	test = [];
	FrameDelta = para.of.FrameDelta;	% frame delta
	for i = 1:FrameDelta:size(imgs,4)-FrameDelta
		% load the two frames
		im1 = imgs(:,:,channels,i);
		im2 = imgs(:,:,channels,i+FrameDelta);
		
		% lower body
		if para.of.lb
			im1 = im1(ceil(size(imgs, 1)/2):end,:,:);
			im2 = im2(ceil(size(imgs, 1)/2):end,:,:);
		end
		
		% this is the core part of calling the mexed dll file for computing optical flow
		% it also returns the time that is needed for two-frame estimation
		[vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,flowPara);
		
		% visualize flow field
		flow(:,:,1) = vx;
		flow(:,:,2) = vy;
		
		switch mode
			case 1
				e = flow(:,:,1).^2+flow(:,:,2).^2;
			case 2
				e = flow(:,:,1).^2;
			case 3
				temp = flow(:,:,1);
				e = abs(temp).^0.5;
			case 4
				temp = flow(:,:,1);
				temp = temp - min(min(temp));
				mid = floor(size(temp,2)/2);
				e = (temp(:,1:mid)-temp(:,mid+1:mid*2)).^2;
			case 5
				temp = flow(:,:,1);
				temp = temp - mean(mean(temp));
				mid = floor(size(temp,2)/2);
				e = (temp(:,1:mid)-temp(:,mid+1:mid*2)).^2;
			case 6
				mid = floor(size(flow,2)/2);
				e = (flow(:,1:mid,1)-flow(:,mid+1:mid*2,1)).^2;
			case 7
				temp = flow(:,:,1);
				mid = floor(size(temp,2)/2);
				e = (temp(:,1:mid)-temp(:,mid+1:mid*2)).^2;
		end
		esum = sum(sum(e));
		E = [E; esum];
		vxMean = [vxMean,mean(vx(:))];
		test = [test,mean(mean(vx(1:20,floor(end/2)-10:floor(end/2)+10)))];
		
		% 	subplot(1,2,1);imshow(imflow);
		% 	subplot(1,2,2);plotflow(flow);
		% 	pause(0.5);
% 		progress('Optical Flow',i,size(imgs,4)-FrameDelta);
    end
    my_mkdir(para.dir.saveOfEnergy);
	save(para.files.EFile, 'E', 'vxMean');
% 	fprintf('\n');
end

end


function [ index, E_g_filt, E_f_filt, indexabs, indexG, indexGabs,...
	indexV, indexVabs ] = fun_2_ofFilter( E, para )
%FUN_2_OFFILTER Summary of this function goes here
%   Detailed explanation goes here

% if exist(para.files.indexFile, 'file')
% 	load(para.files.indexFile);
% end

GaussionSize = para.of.GaussionSize;
fft_f = para.of.fft_f;
FrameDelta = para.of.FrameDelta;

% gaussion filter
if GaussionSize && GaussionSize<length(E)/2-1
	g = fspecial('gaussian',[1,GaussionSize],1);
	E_g_filt = filtfilt(g,1,E);
	x = E_g_filt;
else
	g = fspecial('gaussian',[1,2],1);
	E_g_filt = filtfilt(g,1,E);
	x = step(para.of.Hd,E);
	para.of.Hd.release();
end
% figure(7); plot(E_g_filt);

% % test - limit
% maxR = 2;
% E_g_limit = x;
% E_g_limit(x>mean(x)*maxR) = mean(x);

% for-test
mask = ones(size(x));
maxR = 3;
tempM = x>median(x)*maxR;
k = 5;
if length(mask)>30
    tempN = conv(double(tempM),ones(1,10*2-1),'same');
    mask(tempN==1) = 0;
    mask([1:k end-k+1:end]) = 0;
end
i = (1:length(x))';
% E_f_filt_test1 = feval(my_fourierFit(i, x),i);
% E_f_filt_test2 = feval(my_fourierFit(i(mask==1), x(mask==1)),i);


% fft filter
fs=30;
N=length(x);
%进行FFT变换并做频谱图
y=fft(x,N);%进行fft变换
mag=abs(y);%求幅值

% figure(8); plot(mag);

limit = [0.75 1.5]*2;
ff = limit*length(y)/fs+1;
% selected = ceil(ff(1)):floor(ff(2));
selected = ceil(ff(1)):ceil(ff(2));
pass = ceil(ff(1))-1;
[~,I] = sort(mag(selected),'descend');
fre = floor((I(1)+pass-1)*(fft_f-1)+1);
y_temp = zeros(size(y));
y_temp([1 fre]) = y([1 fre]);

% draw
y_temp([fre(2)]) = 2*y([fre(2)]);

%用IFFT恢复原始信号
xifft=ifft(y_temp);
E_f_filt = real(xifft);

lg = length(E_g_filt);
lf = length(E_f_filt);
if lg~=lf
	E_f_filt = E_f_filt(round(1:(lf-1)/(lg-1):lf));
end


maxL = 0; curL = 0;
for i=1:length(mask)
    if mask(i)==1
        curL = curL+1;
        if curL>=maxL
            maxL=curL;
            mask(1:i-curL)=0;
        end
    else
        if curL<maxL
            mask(i-curL:i-1)=0;
        end
        curL = 0;
    end
end
% figure(2);hold on;plot(mask,'b');   % for-test

% x=x(mask==1);
fs=30;
N=length(x);
y=fft(x,N);%进行fft变换
mag=abs(y);%求幅值
limit = [0.75 1.5]*2;
ff = limit*length(y)/fs+1;
selected = ceil(ff(1)):ceil(ff(2));
pass = ceil(ff(1))-1;
[~,I] = sort(mag(selected),'descend');
fre = floor((I(1)+pass-1)*(fft_f-1)+1);
y_temp = zeros(size(y));
y_temp([1 fre]) = y([1 fre]);
y_temp([fre(2)]) = 2*y([fre(2)]);
xifft=ifft(y_temp);
E_temp = real(xifft);
% i = (1:length(mask))';
% E_f_filt_test3 = feval(my_fourierFit(i(mask==1), E_temp),i);


% figure(10);clf;hold on
% plot(E_g_filt,'b');plot(E_f_filt,'r');    % for-test
% plot(E_f_filt_test1,'k'); plot(E_f_filt_test2,'g');
% plot(E_f_filt_test3,'m'); plot(i(mask==1),E_temp,'y');
% hold off;

if strcmp(para.dir.testIndexN, '13')
    E_f_filt = E_g_filt;
else
    
E_f_filt = E_temp;

end

% index
EE1 = E_f_filt(2:end-1)-E_f_filt(1:end-2);
EE2 = E_f_filt(2:end-1)-E_f_filt(3:end);
index1 = find(EE1'<=0 & EE2'<=0)+1;
index2 = -(find(EE1'>=0 & EE2'>=0)+1);
index = [index1 index2];
[~,I] = sort(abs(index));
index = index(I);
indexabs = abs(index);

% test - indexG
EEG1 = E_g_filt(2:end-1)-E_g_filt(1:end-2);
EEG2 = E_g_filt(2:end-1)-E_g_filt(3:end);
indexG1 = find(EEG1'<=0 & EEG2'<=0)+1;
indexG2 = -(find(EEG1'>=0 & EEG2'>=0)+1);
indexG = [indexG1 indexG2];
[~,I] = sort(abs(indexG));
indexG = indexG(I);
indexGabs = abs(indexG);

% modify - test10/12
temp = [];
for i=1:length(index)
	if i==1
		iBegin = 1;
	else
		iBegin = floor(mean(indexabs(i-1:i)))+1;
	end
	if i==length(index)
		iEnd = length(E_f_filt);
	else
		iEnd = ceil(mean(indexabs(i:i+1)))-1;
	end
	
	[~,I] = sort(abs(indexG-index(i)));
	if (~isempty(indexG)) && indexGabs(I(1))>=iBegin && indexGabs(I(1))<=iEnd
		temp = [temp indexG(I(1))];
	else
		temp = [temp index(i)];
	end
end

indexV = temp;
indexVabs = abs(indexV);

end


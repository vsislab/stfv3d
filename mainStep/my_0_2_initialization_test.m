
if ~exist(roots{dataN},'dir'); roots{dataN}='..\.'; end
para.dir.root = roots{dataN};
[~, dataset] = fileparts(para.dir.root);
if strcmp(dataset,'prid_2011')
	para.dir.loadSequences = [para.dir.root '\multi_shot'];
else
	para.dir.loadSequences = [para.dir.root '\sequences'];
end

para.dir.saveIndexes = [para.dir.root '\results\Index'];
para.dir.saveBBoxes = [para.dir.root '\results\BBox'];
para.dir.saveFeatures = [para.dir.root '\features'];
para.dir.saveComparisions = [para.dir.root '\comparisions'];
para.dir.saveResults = [para.dir.root '\results\Final'];
para.dir.DMLFeatures = [para.dir.root '\results\DML\features'];

[~, dataset] = fileparts(para.dir.root);
if strcmp(dataset,'i-LIDS-VID')
	para.sampleN = min(300,maxSampleN);
	para.indexOmit = [];
elseif strcmp(dataset,'prid_2011')
	para.sampleN = min(200,maxSampleN);
	para.indexOmit = [6,31,52,57,62,94,106,120,138,139,142,145,158,159,166,183,190,199,200];
elseif strcmp(dataset,'SDU-VID')
	para.sampleN = min(300,maxSampleN);
	para.indexOmit = [];
end

para.testNo = testNo;
para.modeLoc = modeLoc;
para.retrain = retrain; % for retrain dataset
para.comparision.methods = methods;
	
rng(para.testNo);
para.crossIndex = crossvalind('Kfold', para.sampleN, para.validationFold);

para.window_size = [128 64];	% 图像大小

% 空间划分
para.part_pos = [...
	23  4 43 24;...
	6 24 33 70;...
	20 24 46 70;...
	33 24 59 70;...
	6 71 32 124;...
	33 71 59 124]';			
para.num_part = size(para.part_pos,2); % Decompose human body into 6 parts: head, torso, arms, legs

para.validationFold			= 2;
para.cam.camProbe			= 1;
para.cam.camGallery			= 2;

para.adaptivemode			= adaptivemode;	% adaptive sequence segmentation
para.of.indexThresholdValue = indexThresholdValue;

if para.useflow
	para.of.color			= 'RGB';
	para.of.channels		= [1 2 3];
	% set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
	para.of.alpha			= 0.012;
	para.of.ratio			= 0.75;
	para.of.minWidth		= 20;
	para.of.nOuterFPIterations = 7;
	para.of.nInnerFPIterations = 1;
	para.of.nSORIterations	= 30;
	
	% of para
	para.of.FrameDelta		= 1;	% 1
	para.of.lb				= true;
	para.of.mode			= 2;	% 1~7
	
	% filter para
	para.of.GaussionSize	= 5;
	para.of.Hd				= my_hamming_filter;
	para.of.fft_f			= [1 2];	% top fft frequence component [1 1.5 2]
	
	para.of.maxR			= 1.6;
end

if para.usefv
	
	% set para
	para.fv.color_mode		= 'HSV';	% available color space RGB, HSV
	para.fv.histeq			= [3];		% channel enhance
	para.fv.channels		= [1 2 3];	% selected channels
	para.fv.Ivalues			= [0 1 2];	% local description variables: 0-I; 1-Id; 2-Idd | [0 1 2], [1 2]
	para.fv.trainMode		= 2;		% 1-gallery; 2-training; 3-gallery & training; 4-probe & training
	
	para.fv.usePart_pos		= usePart_pos;
	para.fv.l_all			= 2;
	para.fv.h_num			= 3;
	para.fv.w_num			= 2;
	para.fv.h_overlap		= 0;
	para.fv.w_overlap		= 0;
	
	para.fv.L				= L;		% sequence length
	para.fv.l_num			= l_num;	% temporal patch
	para.fv.l_body			= [];		% head body patched
	para.fv.sampleSeq		= 'median';	% pca training sampling sequence | 'all','median'
	para.fv.convMode		= 'replicate';		% convMode: 0, 'symmetric', 'replicate' or 'circular'
	para.fv.convInteX		= 2;		% conv interval on x
	para.fv.convInteY		= 2;		% conv interval on y
	para.fv.convInteZ		= 1;		% conv interval on z
	para.fv.sampleRate		= 0.01;		% pca training sampling rate
	para.fv.num_cluster		= 32;		% gmm clusters
	para.fv.pcaCompN		= 12;		% pca NumComponents <=24
	para.fv.try_times		= try_times;		% gmm training try times
	para.fv.WMuSigma		= [2 3];	% fisher vector components - w, mu, sigma | [2 3]

	% train model
	para.fv.train_set_dir	= para.dir.loadSequences;
	para.fv.model_dir		= setdir(fullfile(para.dir.saveFeatures, 'model'));
	para.fv.max_iter		= 1000;		% 1000

end

if para.usehog3d
	para.hog3d.L			= L;
	para.hog3d.l_all		= 2;
	para.hog3d.channels		= [1 2 3];
	
	para.hog3d.usePart_pos	= usePart_pos;	% true - 12%; false - 12.6%
	para.hog3d.h_num		= 3;
	para.hog3d.w_num		= 2;
	para.hog3d.l_num		= l_num;
	para.hog3d.h_overlap	= 0;
	para.hog3d.w_overlap	= 0;
	para.hog3d.l_overlap	= 0;
end

if para.usergb3d
	para.rgb3d.L			= L;
	para.rgb3d.l_all		= 2;
	
	para.rgb3d.usePart_pos	= usePart_pos;
	para.rgb3d.color_mode	= 'HSVYUV'; % available color space RGB, HSV
	para.rgb3d.histeq		= [];
	para.rgb3d.channels		= [1:6];
	para.rgb3d.nbins		= 8;
    para.rgb3d.moments      = [1 2 3];
	para.rgb3d.nind			= 2;
	para.rgb3d.h_num		= 8;
	para.rgb3d.w_num		= 8;
	para.rgb3d.l_num		= l_num;
	para.rgb3d.h_overlap	= 0;
	para.rgb3d.w_overlap	= 0;
	para.rgb3d.l_overlap	= 0;
end

if para.uselbp
	para.lbp.L				= L;
	para.lbp.l_all			= 2;
	
	para.lbp.usePart_pos	= usePart_pos;
	para.lbp.color_mode		= 'HSV';	% 'RGB' or 'HSV'
	para.lbp.histeq			= [];
	para.lbp.channels		= [3];
	para.lbp.h_num			= 4;
	para.lbp.w_num			= 4;
	para.lbp.l_num			= l_num;
	para.lbp.h_overlap		= 0;
	para.lbp.w_overlap		= 0;
	para.lbp.l_overlap		= 0;
	
	% for LBP
	para.lbp.RotateIndex	= 1;
	para.lbp.TInterval		= 2;
	para.lbp.TimeLength		= 2;
	para.lbp.BorderLength	= 1;
	para.lbp.bBilinearInterpolation = 0;
	para.lbp.Type			= 'LBPTOP';	% 'VLBP' or 'LBPTOP'
	
	% for 'VLBP' only
	para.lbp.FRadius		= 1;
	para.lbp.NeighborPointsV = 4;
	
	% for 'LBPTOP' only
	para.lbp.FxRadius		= 1;
	para.lbp.FyRadius		= 1;
	para.lbp.Bincount		= 59;	% 59 or 0
	para.lbp.NeighborPointsL = [8 8 8];
	if para.lbp.Bincount == 0
		para.lbp.Code		= 0;
	else
		U8File = importdata('UniformLBP8.txt');
		para.lbp.Code		= U8File(2 : end, :);
		clear U8File;
	end
end

para.useml = useml;
if ~numCoeffs; para.useml = false; end
if para.useml
	para.ml.p.numCoeffs		= numCoeffs; %dimensionality reduction by PCA to 34 dimension
	para.ml.p.negN			= 1; % negative samples rate
	para.ml.p.testN			= 1;
	para.ml.p.N				= para.sampleN; %number of image pairs, 316 to train 316 to test
	para.ml.p.pmetric		= 0;
	para.ml.p.mu			= 0; % smothing parameters see below
	para.ml.p.sigma			= 1;
    
	para.ml.pair_metric_learn_algs = {...
		LearnAlgoKISSME(para.ml.p), ...
		LearnAlgoMahal(), ...
		LearnAlgoLFDA(), ...LearnAlgoMLEuclidean(), ...	LearnAlgoITML(), ...     LearnAlgoLDML(), ...     LearnAlgoLMNN() ...
		};
	
end

if strcmp(dataset,'prid_2011')
	para.fv.Ivalues			= [1];
else
	para.fv.Ivalues			= [0 1 2];
end


f							= 1;
para.testPer				= find(para.crossIndex'==f);
para.trainPer				= find(para.crossIndex'~=f);
para.f						= f;

para.ii                     = 1;
para.randN                  = false;
para.maxN                   = 99;
para.ml.uselfda             = uselfda;


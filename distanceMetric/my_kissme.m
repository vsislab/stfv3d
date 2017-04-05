clear;
close all;
addpath('helper');
addpath('learnAlgos');
addpath(genpath('lib'));
addpath('utility');

DATA_OUT_DIR = 'D:\Liukan\Dataset\i-LIDS-VID\results\DML';

for readDirs = {'106'}
% for readDirs = {'26'}
params.readDir = [DATA_OUT_DIR,'\features',readDirs{1}];
numCoeffss = [50:50:200];
params.saveResults = false;

% Set up parameters
params.numCoeffs = 50; %dimensionality reduction by PCA to 34 dimension
params.negN = 1; % negative samples rate
params.testN = 1;
params.N = 300; %number of image pairs, 316 to train 316 to test
params.saveDir = fullfile(DATA_OUT_DIR,'all');
params.pmetric = 0;
params.mu = 0; % smothing parameters see below
params.sigma =1;

pair_metric_learn_algs = {...
	LearnAlgoKISSME(params), ...
	LearnAlgoMahal(), ...
	LearnAlgoMLEuclidean(), ...	LearnAlgoITML(), ...     LearnAlgoLDML(), ...     LearnAlgoLMNN() ...
	};

% Load Features
fmats = my_dir(params.readDir);
for c = 1:length(fmats)
% for c = length(fmats)	% test
	
	clear ux;
	load(fmats{c});
	
	if ~exist('ux','var')
		%-- gaussian smoothing of the attribute features see [13] for details --%
		X = ft;
		g = normpdf(X.*0.5,params.mu,params.sigma);
		X = X .* g;
		[ux,u,m] = applypca(X);
		save(fmats{c}, 'para','ft','ftInfo','ux');
	end
	
	uxs{c} = ux;
end

for numCoeffs = numCoeffss
params.numCoeffs = numCoeffs;

% Cross-validate over a number of runs
ds = [];

% fmats = my_dir(params.readDir);
for c = 1:length(fmats)
% for c = length(fmats)	% test
	for i = 1:params.testN
		[ ds ] = CrossValidateViper(ds, pair_metric_learn_algs,double(uxs{c}(1:params.numCoeffs,:)),ftInfo,params,para);
	end
end

% Plot Cumulative Matching Characteristic (CMC) Curves
names = fieldnames(ds);
for nameCounter=1:length(names)
   s = [ds.(names{nameCounter})];
   ms.(names{nameCounter}).cmc = cat(1,s.cmc)./(params.N/2);
   ms.(names{nameCounter}).roccolor = s(1).roccolor;
end

h = figure;
names = fieldnames(ms);
fprintf('test: C=%3d, N=%1d -',params.numCoeffs,params.negN);
for nameCounter=1:length(names)
	cmcTemp = mean(ms.(names{nameCounter}).cmc,1);
   hold on; plot(cmcTemp,'LineWidth',2, ...
       'Color',ms.(names{nameCounter}).roccolor);
   fprintf('\t%2.2f%%',cmcTemp(1)*100);
end

title('Cumulative Matching Characteristic (CMC) Curves - VIPeR dataset');
box('on');
set(gca,'XTick',[0 5 10 20 50 100 150 200 250 300 350]);
ylabel('Matches');
xlabel('Rank');
xlim([0 25]);
ylim([0 1]);

% plot fv-knn
load([params.saveDir,'\fvResults.mat']);
plot(rank0Precisions,'b','LineWidth',2);
fprintf('\t%2.2f%%',rank0Precisions(1)*100);

% plot state-of-the-art
plot([1 5 10 20],[0.345 0.567 0.675 0.775],'k','LineWidth',2);
fprintf('\t%2.2f%%',0.345*100);

legend([upper(names);'FV-KNN';'STATE'],'Location','SouthEast');
hold off;
grid on;

if params.saveResults
	add = ['-C',num2str(params.numCoeffs),'-N',num2str(params.negN)];
    exportAndCropFigure(h,['fig_i-LIDS-VID',add],params.saveDir);
    save([params.saveDir,'\data\dat_i-LIDS-VID',add,'.mat'],'ds');
end
fprintf('\tDone!\n');

end

end

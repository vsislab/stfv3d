clear; close all;

addpath('mainStep');                % for spatial-temporal fisher vector extraction
addpath(genpath('opticalFlow'));	% optical flow tools
addpath('walkingCycle');            % for walking cycle extraction
addpath('localDescriptors');        % local descriptor calculation
addpath('fisherVector');            % fisher vector tools
addpath('hog3d');					% hog3d tools
addpath(genpath('distanceMetric')); % distance metric learning tools
addpath('utility');

roots{1} = '..\Dataset\i-LIDS-VID';
roots{2} = '..\Dataset\PRID\prid_2011';
roots{3} = '..\Dataset\SDU-VID';

for testNo = [0] % [0:9] run experiments again and again

clear para;
my_0_1_paraSettings;

for dataN = 1:length(roots)
    para.dataN = dataN;

	my_0_2_initialization_test;
    
	para                = my_0_4_getIndex_test(para);
    para                = my_0_5_getBBox_test(para);
	para                = my_0_6_getFvModel_test(para);
	[features, para]    = my_1_featureExtraction_test( para.indexes, para );
	comparisions        = my_2_directlyProcess_test( features, para);
	[results, maxRank1] = my_3_directlyEvaluate_test( comparisions, para );
	
    my_mkdir(para.dir.saveResults);
	save([para.dir.saveResults '\result.mat'], 'results', 'para', 'maxRank1');
    
	fprintf('Result of dataset-%1d >>\t', para.dataN);
	fprintf('%.1f  ', maxRank1*100); fprintf('\n');
    
end % for dataN
end % for testNo


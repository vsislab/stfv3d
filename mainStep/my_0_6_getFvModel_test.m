function [ para ] = my_0_6_getFvModel_test( para )
%MY_0_6_GETFVMODEL_TEST Summary of this function goes here
%   Detailed explanation goes here

if para.usefv
    para.fv.nameSet = ['-N' num2str(para.testNo)];
	
	% for test names
	if isfield(para, 'testname')
		para.fv.nameSet = [...
			'-' para.testname...
			para.fv.nameSet];
	end
	
	para.fv.nameMode = para.fv.nameSet;
		
	para.fv.fvModelFile = [para.fv.model_dir,'\Body-Action_model',...
		para.fv.nameMode '.mat'];
	
	if exist(para.fv.fvModelFile, 'file') && ~para.retrain
		fvModel = load(para.fv.fvModelFile);
		para.fv = mergeVar(para.fv, fvModel);
	else
		para = learn_fisher_vector_model( para );
	end
end

end


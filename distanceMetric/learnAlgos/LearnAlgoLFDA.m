%LEARNALGOITML Wrapper class to the actual LFDA code
classdef LearnAlgoLFDA < LearnAlgo
    
    properties 
       p %parameters 
       s %struct
       available
       perIdx
    end
    
    properties (Constant)
        type = 'lfda'
    end
    
    methods
        function obj = LearnAlgoLFDA(p)
           if nargin < 1
              p = struct(); 
           end
           
           if ~isfield(p,'roccolor')
                p.roccolor = 'c';
           end
           
%            if ~isunix
%                 display('Warning LDML may not work properly!');
%                 obj.available = 0;
%                 return;
%             end
           
           obj.p  = p;
           check(obj);
        end
        
        function bool = check(obj)
           bool = exist('lfda') ~= 0;
           if ~bool
               fprintf('Sorry %s not available\n',obj.type);
           end
           obj.available = bool;
        end
        
        function obj = setIndex(obj,perIdx)
            obj.perIdx = perIdx;
        end
        
        function s = learnPairwise(obj,X,idxa,idxb,matches)   
            if ~obj.available
                s = struct();
                return;
            end
            
            idxTrain = unique(idxa);
            X = X(:,idxTrain);
            Y = obj.perIdx(idxTrain)';
%             X = X(:,[idxa(matches) idxb(matches)])'; %m x d
%             Y = [1:sum(matches) 1:sum(matches)]';
            tic;
            s.L = LFDA(X,Y,min(50,size(X,1)),'weighted',1);
            s.M = s.L*s.L';
            s.t = toc;
            s.learnAlgo = obj;
            s.roccolor = obj.p.roccolor;
        end
        
%         function s = learn(obj,X,y)
%             if ~obj.available
%                 s = struct();
%                 return;
%             end
%             
%             tic;
%             s.M = MetricLearning(@ItmlAlg, y', X');
%             s.t = toc; 
%             s.learnAlgo = obj;
%             s.roccolor = obj.p.roccolor;
%         end
        
        function d = dist(obj, s, X, idxa,idxb)
            d = cdistM(s.M,X,idxa,idxb);
        end
    end    
end


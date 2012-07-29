classdef TestRTrees
    %TestRTrees
    properties (Constant)
    end
    
    methods (Static)        
        function test_1
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = [ones(50,1);-ones(50,1)];
            classifier = cv.RTrees;
            classifier.train(X,Y,'VarType','Regression');
            Yhat = classifier.predict(X);
        end
        
        function test_2
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = [ones(50,1);-ones(50,1)];
            classifier = cv.RTrees;
            classifier.train(X,Y,'CalcVarImportance',true);
            Yhat = classifier.predict(X);
            %classifier.get_train_error;
            classifier.getVarImportance;
            P = classifier.predict_prob(X);
        end
    end
    
end


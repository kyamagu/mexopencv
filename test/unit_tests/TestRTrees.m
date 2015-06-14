classdef TestRTrees
    %TestRTrees
    properties (Constant)
    end
    
    methods (Static)        
        function test_1
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = double([ones(50,1);-ones(50,1)]);
            classifier = cv.RTrees;
            classifier.train(X,Y);
            Yhat = classifier.predict(X);
        end
        
        function test_2
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = [ones(50,1);-ones(50,1)];
            classifier = cv.RTrees;
            classifier.CalculateVarImportance = true;
            classifier.train(X,Y);
            Yhat = classifier.predict(X);
            classifier.getVarImportance();
        end
    end
    
end


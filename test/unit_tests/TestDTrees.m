classdef TestDTree
    %TestDTree
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = [ones(50,1);-ones(50,1)];
            classifier = cv.DTree;
            classifier.train(X,Y);
            Yhat = classifier.predict(X);
        end
    end
    
end


classdef TestKNearest
    %TestKNearest
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = [ones(50,1);-ones(50,1)];
            classifier = cv.KNearest;
            classifier.train(X,Y);
            [Yhat,neiResp,dists] = classifier.find_nearest(X,'K',5);
        end
    end
    
end


classdef TestSVM
    %TestSVM
    properties (Constant)
    end
    
    methods (Static)
    	function test_1
            % classification
    		X = [randn(50,3)+1;randn(50,3)-1];
    		Y = [ones(50,1);-ones(50,1)];
    		classifier = cv.SVM;
    		classifier.train(X,Y);
    		Yhat = classifier.predict(X);
        end
        
    	function test_2
            % regression
    		X = [randn(50,3)+1;randn(50,3)-1];
    		Y = [ones(50,1);-ones(50,1)]+randn(100,1)*0.5;
    		regressor = cv.SVM;
    		regressor.train(X,Y,'SVMType','EPS_SVR','P',0.001);
    		Yhat = regressor.predict(X);
    	end
    	
    	function test_3
            % train auto
    		X = [randn(50,3)+1;randn(50,3)-1];
    		Y = [ones(50,1);-ones(50,1)];
    		classifier = cv.SVM;
    		classifier.train_auto(X,Y,'KFold',2);
    		Yhat = classifier.predict(X);
    	end
    end
    
end


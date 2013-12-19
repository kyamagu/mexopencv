classdef TestSVM
    %TestSVM
    properties (Constant)
        X = [randn(50,3)+1;randn(50,3)-1];
        Y = [ones(50,1);-ones(50,1)];
        YReg = [ones(50,1);-ones(50,1)]+randn(100,1)*0.5;
    end
    
    methods (Static)
        function test_1
            % classification
            classifier = cv.SVM;
            classifier.train(TestSVM.X, TestSVM.Y);
            Yhat = classifier.predict(TestSVM.X);
            assert(isscalar(classifier.VarCount));
            assert(isstruct(classifier.Params));
            assert(isscalar(classifier.SupportVectorCount));
            assert(isvector(classifier.getSupportVector(0)));
        end
        
        function test_2
            % regression
            regressor = cv.SVM;
            regressor.train(TestSVM.X, TestSVM.YReg, ...
                'SVMType','EPS_SVR', 'P',0.001);
            Yhat = regressor.predict(TestSVM.X);
        end
        
        function test_3
            % train auto
            classifier = cv.SVM;
            classifier.train_auto(TestSVM.X, TestSVM.Y, 'KFold',2);
            Yhat = classifier.predict(TestSVM.X);
        end
    end
    
end


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
        
        function test_4
            % predict_all
            classifier = cv.SVM;
            classifier.train(TestSVM.X, TestSVM.Y);
            Yhat1 = classifier.predict(TestSVM.X);
            Yhat2 = classifier.predict_all(TestSVM.X);
            assert(isequal(Yhat1,Yhat2));
        end
        
        function test_5
            % VarIdx/SampleIdx
            [n,d] = size(TestSVM.X);
            classifier = cv.SVM;
            
            classifier.train(TestSVM.X, TestSVM.Y, ...
                'VarIdx',[], 'SampleIdx',[]);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train(TestSVM.X, TestSVM.Y, ...
                'VarIdx',(1:d)-1, 'SampleIdx',(1:n)-1);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train(TestSVM.X, TestSVM.Y, ...
                'VarIdx',true(1,d), 'SampleIdx',true(1,n));
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train(TestSVM.X, TestSVM.Y, 'VarIdx',[0,2]);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train(TestSVM.X, TestSVM.Y, 'VarIdx',[true,false,true]);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train(TestSVM.X, TestSVM.Y, 'SampleIdx',0:n/2);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train(TestSVM.X, TestSVM.Y, 'SampleIdx',rand(n,1)>0.5);
            Yhat = classifier.predict(TestSVM.X);
        end
        
        function test_6
            % save/load
            fname = tempname;
            classifier = cv.SVM(TestSVM.X, TestSVM.Y);
            
            classifier.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            c1 = cv.SVM();
            c1.load([fname '.xml']);
            %isequal(classifier, c1)
            
            classifier.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            c2 = cv.SVM();
            c2.load([fname '.yaml']);
            %isequal(classifier, c2)
            
            c1.clear();
            c2.clear();
        end
    end
    
end


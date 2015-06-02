classdef TestSVM
    %TestSVM
    properties (Constant)
        X = [randn(50,3)+1;randn(50,3)-1];
        Y = int32([ones(50,1);-ones(50,1)]);
        YReg = [ones(50,1);-ones(50,1)]+randn(100,1)*0.5;
    end
    
    methods (Static)
        function test_1
            % classification
            classifier = cv.SVM;
            classifier.Type = 'C_SVC';
            classifier.KernelType = 'RBF';
            classifier.C = 1;
            classifier.Gamma = 1;
            classifier.train(TestSVM.X, TestSVM.Y);
            Yhat = classifier.predict(TestSVM.X);
            assert(classifier.isClassifier());
            assert(classifier.isTrained())
            assert(ismatrix(classifier.getSupportVectors()));
            assert(isscalar(classifier.getVarCount));
            [alpha,svidx,rho] = classifier.getDecisionFunction(0);
        end
        
        function test_2
            % regression
            regressor = cv.SVM;
            regressor.Type = 'EPS_SVR';
            regressor.P = 0.001;
            regressor.train(TestSVM.X, TestSVM.YReg);
            Yhat = regressor.predict(TestSVM.X);
            assert(~regressor.isClassifier());
        end
        
        function test_3
            % train auto
            classifier = cv.SVM;
            classifier.trainAuto(TestSVM.X, TestSVM.Y, 'KFold',2);
            Yhat = classifier.predict(TestSVM.X);
        end

        function test_5
            % VarIdx/SampleIdx
            [n,d] = size(TestSVM.X);
            classifier = cv.SVM;
            
            classifier.train_(TestSVM.X, TestSVM.Y, ...
                'VarIdx',[], 'SampleIdx',[]);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train_(TestSVM.X, TestSVM.Y, ...
                'VarIdx',(1:d)-1, 'SampleIdx',(1:n)-1);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train_(TestSVM.X, TestSVM.Y, ...
                'VarIdx',true(1,d), 'SampleIdx',true(1,n));
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train_(TestSVM.X, TestSVM.Y, 'VarIdx',[0,2]);
            Yhat = classifier.predict(TestSVM.X(:,[0 2]+1));
            
            classifier.train_(TestSVM.X, TestSVM.Y, 'VarIdx',[true,false,true]);
            Yhat = classifier.predict(TestSVM.X(:,[true,false,true]));
            
            classifier.train_(TestSVM.X, TestSVM.Y, 'SampleIdx',[1:20 51:70]-1);
            Yhat = classifier.predict(TestSVM.X);
            
            classifier.train_(TestSVM.X, TestSVM.Y, 'SampleIdx',rand(n,1)>0.5);
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

        function test_7
            % custom kernel
            if (false)
                model = cv.SVM();
                model.setCustomKernel('my_kernel');
                model.train(TestSVM.X, TestSVM.Y);
                Yhat = model.predict(TestSVM.X);
            end
        end
    end
    
end

% custom kernel
function results = my_kernel(vecs, another)
    [n,vcount] = size(vecs);
    results = zeros(1, vcount, 'single');
    for i=1:vcount
        results(i) = dot(another, vecs(:,i));
    end
    %results = another.' * vecs;
end

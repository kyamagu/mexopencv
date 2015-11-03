classdef TestSVM
    %TestSVM
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1];
        Y = int32([ones(50,1); -ones(50,1)]);
        YReg = [ones(50,1); -ones(50,1)] + randn(100,1)*0.5;
    end

    methods (Static)
        function test_classification1
            % 2-class (binary)
            model = cv.SVM();
            model.Type = 'C_SVC';
            model.KernelType = 'RBF';
            model.C = 1;
            model.Gamma = 1;
            model.TermCriteria.maxCount = 1000;
            model.TermCriteria.epsilon = 1e-6;

            assert(~model.isTrained());
            success = model.train(TestSVM.X, TestSVM.Y);
            validateattributes(success, {'logical'}, {'scalar'});
            assert(model.isTrained());
            assert(model.isClassifier());
            varcount = model.getVarCount();
            validateattributes(varcount, {'numeric'}, {'scalar'});
            assert(varcount == size(TestSVM.X,2));

            sv = model.getSupportVectors();
            validateattributes(sv, {'numeric'}, {'size',[NaN varcount]});
            [alpha,svidx,rho] = model.getDecisionFunction(0);
            validateattributes(alpha, {'numeric'}, ...
                {'vector', 'numel',numel(svidx)});
            validateattributes(svidx, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative', '<',size(sv,1)});
            validateattributes(rho, {'numeric'}, {'scalar'});

            Yhat = model.predict(TestSVM.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer' 'numel',numel(TestSVM.Y)});
            Yhat = int32(Yhat);
            assert(all(ismember(unique(Yhat), unique(TestSVM.Y))));
            acc = nnz(Yhat == TestSVM.Y) / numel(TestSVM.Y);
        end

        function test_classification2
            % we load data from Statistics Toolbox
            if ~license('test', 'statistics_toolbox') || isempty(ver('stats'))
                disp('SKIP');
                return;
            end

            % 3-class (multiclass)
            data = load('fisheriris');
            X = data.meas;
            Y = int32(grp2idx(data.species));
            trainIdx = unique([1:3:numel(Y), 2:3:numel(Y)]);
            testIdx = setdiff(1:numel(Y), trainIdx);

            model = cv.SVM();
            model.Type = 'C_SVC';
            model.KernelType = 'RBF';
            model.C = 0.1;
            model.Gamma = 0.05;
            model.train(X(trainIdx,:), Y(trainIdx,:));

            C = numel(unique(Y));  % number of classes
            sv = model.getSupportVectors();
            validateattributes(sv, {'numeric'}, {'size',[NaN size(X,2)]});
            for k=1:(C*(C-1)/2)    % one-vs-one
                [alpha,svidx,rho] = model.getDecisionFunction(k-1);
                validateattributes(alpha, {'numeric'}, ...
                    {'vector', 'numel',numel(svidx)});
                validateattributes(svidx, {'numeric'}, ...
                    {'vector', 'integer', 'nonnegative', '<',size(sv,1)});
                validateattributes(rho, {'numeric'}, {'scalar'});
            end

            Yhat = model.predict(X(testIdx,:));
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer' 'numel',numel(testIdx)});
            Yhat = int32(Yhat);
            assert(all(ismember(unique(Yhat), unique(Y))));
            acc = nnz(Yhat == Y(testIdx)) / numel(testIdx);
        end

        function test_regression
            model = cv.SVM();
            model.Type = 'EPS_SVR';
            model.P = 0.001;
            model.C = 1;
            model.train(TestSVM.X, TestSVM.YReg);
            assert(~model.isClassifier());
            Yhat = model.predict(TestSVM.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'real' 'numel',numel(TestSVM.YReg)});
            err = norm(Yhat - TestSVM.YReg);
        end

        function test_param_grid_search
            model = cv.SVM();
            model.Type = 'C_SVC';
            model.KernelType = 'RBF';
            grid = struct('minVal',0, 'maxVal',1, 'logStep',0);
            model.trainAuto(TestSVM.X, TestSVM.Y, 'KFold',2, ...
                'CGrid','C', 'GammaGrid','Gamma', 'PGrid',grid, ...
                'NuGrid',grid, 'CoeffGrid',grid, 'DegreeGrid',grid);
            Yhat = model.predict(TestSVM.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer' 'numel',numel(TestSVM.Y)});
            %TODO: https://github.com/Itseez/opencv/pull/4174
            %assert(all(ismember(unique(Yhat), [1;-1])));  %TODO: [0;1] not [-1;1]?
        end

        function test_data_options1
            % VarIdx/SampleIdx
            [N,d] = size(TestSVM.X);
            model = cv.SVM();

            model.clear();
            model.train(TestSVM.X, TestSVM.Y, ...
                'Data',{'VarIdx',[], 'SampleIdx',[]});
            Yhat = model.predict(TestSVM.X);

            model.clear();
            model.train(TestSVM.X, TestSVM.Y, ...
                'Data',{'VarIdx',(1:d)-1, 'SampleIdx',(1:N)-1});
            Yhat = model.predict(TestSVM.X);

            model.clear();
            model.train(TestSVM.X, TestSVM.Y, ...
                'Data',{'VarIdx',true(1,d), 'SampleIdx',true(1,N)});
            Yhat = model.predict(TestSVM.X);

            model.clear();
            model.train(TestSVM.X, TestSVM.Y, ...
                'Data',{'VarIdx',[0,2]});
            Yhat = model.predict(TestSVM.X(:,[0 2]+1));

            model.clear();
            model.train(TestSVM.X, TestSVM.Y, ...
                'Data',{'VarIdx',[true,false,true]});
            Yhat = model.predict(TestSVM.X(:,[true,false,true]));

            model.clear();
            model.train(TestSVM.X, TestSVM.Y, ...
                'Data',{'SampleIdx',[1:20 51:70]-1});
            Yhat = model.predict(TestSVM.X);

            model.clear();
            model.train(TestSVM.X, TestSVM.Y, ...
                'Data',{'SampleIdx',rand(N,1)>0.5});
            Yhat = model.predict(TestSVM.X);
        end

        function test_data_options2
            model = cv.SVM();
            model.KernelType = 'RBF';

            N = size(TestSVM.X, 1);
            model.train(TestSVM.X, TestSVM.Y, 'Data',{...
                'Layout','Row', 'VarType','NNNC', 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});

            model.clear();
            model.Type = 'EPS_SVR';
            model.P = 0.001;
            model.train(TestSVM.X, TestSVM.YReg, ...
                'Data',{'VarType','NNNN'});
        end

        function test_storage
            fname = tempname();
            model = cv.SVM(TestSVM.X, TestSVM.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.SVM();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.SVM();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.SVM(TestSVM.X, TestSVM.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.SVM();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestSVM.X);

            model3 = cv.SVM();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestSVM.X);
        end

        function test_custom_kernel
            % skip test if external M-file is not found on the path
            if ~exist('my_linear_kernel.m', 'file')
                disp('SKIP')
                return
            end

            % temporarily disable threads
            num = cv.Utils.getNumThreads();
            cv.Utils.setNumThreads(1);
            cleanObj = onCleanup(@() cv.Utils.setNumThreads(num));

            % train/predict using custom kernel
            model = cv.SVM();
            model.setCustomKernel('my_linear_kernel');
            model.train(TestSVM.X, TestSVM.Y);
            Yhat = model.predict(TestSVM.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(TestSVM.Y)});
            assert(all(ismember(unique(Yhat), [1;-1])));
        end
    end

end

% custom kernel
% TODO: this needs to be on the path as a saved function in its own M-file
function results = my_linear_kernel(vecs, another)
    [vcount,n] = size(vecs);
    results = zeros(vcount, 1, 'single');
    for i=1:vcount
        results(i) = dot(vecs(i,:), another);
    end
    %results = vecs * another.';
end

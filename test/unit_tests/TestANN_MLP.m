classdef TestANN_MLP
    %TestANN_MLP
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1];
        Y = [ones(50,1); -ones(50,1)];
        YReg = [ones(50,1); -ones(50,1)] + randn(100,1)*0.5;
    end

    methods (Static)
        function test_classification1
            model = cv.ANN_MLP();
            model.LayerSizes = [3,1];  % 1 output node
            model.TermCriteria.maxCount = 100;
            model.TermCriteria.epsilon = 1e-5;
            model.TrainMethod = 'RProp';
            model.BackpropWeightScale = 0.05;
            model.BackpropMomentumScale = 0.05;
            model.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);
            model.train(TestANN_MLP.X, TestANN_MLP.Y);
            assert(model.isTrained());
            for i=1:numel(model.LayerSizes)
                w = model.getWeights(i-1);
                validateattributes(w, {'numeric'}, {});  %TODO: sizes
            end
            assert(isequal(model.getVarCount(), size(TestANN_MLP.X,2)));

            Yhat = model.predict(TestANN_MLP.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'numel',numel(TestANN_MLP.Y)});
            Yhat = sign(Yhat);
            acc = nnz(Yhat == TestANN_MLP.Y) / numel(Yhat);
        end

        function test_classification2
            Y = double([TestANN_MLP.Y==-1, TestANN_MLP.Y==+1]);
            model = cv.ANN_MLP();
            model.LayerSizes = [3,2];  % 2 output nodes (1-of-N encoding)
            model.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);
            model.train(TestANN_MLP.X, Y);
            Yhat = model.predict(TestANN_MLP.X);
            validateattributes(Yhat, {'numeric'}, {'size',size(Y)});
            [~,pred] = max(Yhat, [], 2);
            pred = pred*2 - 3;    % [1 2] -> [-1 1]
            acc = nnz(pred == TestANN_MLP.Y) / numel(pred);
        end

        function test_classification3
            % we load data from Neural Network toolbox
            if ~license('test', 'Neural_Network_Toolbox') || isempty(ver('nnet'))
                disp('SKIP');
                return;
            end

            load simpleclass_dataset
            X = simpleclassInputs';   % 1000x2
            Y = simpleclassTargets';  % 1000x4 (1-of-N encoded)
            [~,labels] = max(Y, [], 2);
            trainIdx = 1:500;
            testIdx = 501:1000;

            model = cv.ANN_MLP();
            model.LayerSizes = [size(X,2) 10 size(Y,2)];
            model.TrainMethod = 'Backprop';
            model.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);
            model.train(X(trainIdx,:), Y(trainIdx,:));
            Yhat = model.predict(X(testIdx,:));
            validateattributes(Yhat, {'numeric'}, ...
                {'size',[numel(testIdx) size(Y,2)]});

            [~,pred] = max(Yhat, [], 2);
            acc = nnz(labels(testIdx,:) == pred) / numel(testIdx);
        end

        function test_regression1
            model = cv.ANN_MLP();
            model.LayerSizes = [3,1];
            model.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);
            model.train(TestANN_MLP.X, TestANN_MLP.YReg);
            Yhat = model.predict(TestANN_MLP.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'real' 'numel',numel(TestANN_MLP.YReg)});
            err = norm(Yhat - TestANN_MLP.YReg);
        end

        function test_regression2
            % we load data from Neural Network toolbox
            if ~license('test', 'Neural_Network_Toolbox') || isempty(ver('nnet'))
                disp('SKIP');
                return;
            end

            load simplefit_dataset
            X = simplefitInputs';   % 94x1
            Y = simplefitTargets';  % 94x1
            trainIdx = 1:3:numel(X);
            testIdx = setdiff(1:numel(X), trainIdx);

            model = cv.ANN_MLP();
            model.LayerSizes = [1 5 1];
            model.TrainMethod = 'Backprop';
            model.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);
            model.train(X(trainIdx,:), Y(trainIdx));
            Yhat = model.predict(X(testIdx,:));
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'numel',numel(testIdx)});
            err = norm(Yhat - Y(testIdx));
        end

        function test_data_options
            model = cv.ANN_MLP();
            model.LayerSizes = [3,1];

            N = size(TestANN_MLP.X, 1);
            model.train(TestANN_MLP.X, TestANN_MLP.Y, 'Data',{...
                'Layout','Row', 'VarType','NNNN', ...
                'VarIdx',[], 'SampleIdx',[], 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});
        end

        function test_storage
            fname = tempname();
            model = cv.ANN_MLP();
            model.LayerSizes = [3,1];
            model.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);
            model.train(TestANN_MLP.X, TestANN_MLP.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.ANN_MLP();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.ANN_MLP();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.ANN_MLP();
            model.LayerSizes = [3,1];
            model.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);
            model.train(TestANN_MLP.X, TestANN_MLP.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.ANN_MLP();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestANN_MLP.X);

            model3 = cv.ANN_MLP();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestANN_MLP.X);
        end
    end

end

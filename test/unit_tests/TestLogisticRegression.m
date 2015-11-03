classdef TestLogisticRegression
    %TestLogisticRegression
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1];
        Y = [ones(50,1); -ones(50,1)];
    end

    methods (Static)
        function test_classification1
            % 2-class (binary)
            X = TestLogisticRegression.X;
            Y = TestLogisticRegression.Y;
            model = cv.LogisticRegression();
            model.LearningRate = 0.05;
            model.Iterations = 1000;
            model.Regularization = 'L2';
            model.TrainMethod = 'MiniBatch';
            model.MiniBatchSize = 10;

            model.train(X, Y);
            assert(model.isTrained());
            varcount = model.getVarCount();
            assert(isequal(varcount, size(X,2)+1));  % +1 for column of ones
            thetas = model.getLearntThetas();
            validateattributes(thetas, {'numeric'}, {'size',[1 varcount]});

            Yhat = model.predict(X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(Y)});
            assert(all(ismember(unique(Yhat), unique(Y))));
            acc = nnz(Y == Yhat) / numel(Y);
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
            Y = grp2idx(data.species);
            trainIdx = unique([1:3:numel(Y), 2:3:numel(Y)]);
            testIdx = setdiff(1:numel(Y), trainIdx);

            model = cv.LogisticRegression();
            model.LearningRate = 0.01 * size(X,1);
            model.Iterations = 1000;
            model.TermCriteria.maxCount = model.Iterations;
            model.TermCriteria.epsilon = model.LearningRate;
            model.Regularization = 'L2';
            model.TrainMethod = 'Batch';
            model.train(X(trainIdx,:), Y(trainIdx,:));

            C = numel(unique(Y));  % number of classes
            varcount = model.getVarCount();
            assert(isequal(varcount, size(X,2)+1));
            thetas = model.getLearntThetas();
            validateattributes(thetas, {'numeric'}, {'size',[C varcount]});

            Yhat = model.predict(X(testIdx,:));
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer' 'numel',numel(testIdx)});
            assert(all(ismember(unique(Yhat), unique(Y))));
            acc = nnz(Yhat == Y(testIdx)) / numel(testIdx);
        end

        function test_data_options
            model = cv.LogisticRegression();
            N = size(TestLogisticRegression.X, 1);
            model.train(TestLogisticRegression.X, TestLogisticRegression.Y, ...
                'Data',{'Layout','Row', 'VarType','NNNC', ...
                'VarIdx',[], 'SampleIdx',[], 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});
        end

        function test_storage
            fname = tempname();
            model = cv.LogisticRegression(...
                TestLogisticRegression.X, TestLogisticRegression.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.LogisticRegression();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.LogisticRegression();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.LogisticRegression(...
                TestLogisticRegression.X, TestLogisticRegression.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.LogisticRegression();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestLogisticRegression.X);

            model3 = cv.LogisticRegression();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestLogisticRegression.X);
        end
    end

end

classdef TestKNearest
    %TestKNearest
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1];
        Y = int32([ones(50,1); -ones(50,1)]);
        YReg = [ones(50,1); -ones(50,1)] + randn(100,1)*0.5;
    end

    methods (Static)
        function test_classification1
            % 2-class (binary)
            K = 5;  % number of nearest neighbors
            model = cv.KNearest();
            model.DefaultK = K;
            model.AlgorithmType = 'BruteForce';
            model.IsClassifier = true;
            model.train(TestKNearest.X, TestKNearest.Y);

            Yhat = model.predict(TestKNearest.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(TestKNearest.Y)});
            acc = nnz(TestKNearest.Y == Yhat) / numel(Yhat);

            N = size(TestKNearest.X, 1);
            [Yhat, neiResp, dists] = model.findNearest(TestKNearest.X, K);
            Yhat = int32(Yhat);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',N});
            assert(all(ismember(unique(Yhat), unique(TestKNearest.Y))));
            validateattributes(neiResp, {'numeric'}, ...
                {'integer', 'size',[N K]});
            validateattributes(dists, {'numeric'}, ...
                {'2d', 'real', 'size',[N K]});
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

            K = 5;  % number of nearest neighbors
            model = cv.KNearest();
            model.DefaultK = K;
            %model.AlgorithmType = 'KDTree';  % TODO: hangs!
            model.IsClassifier = true;

            model.train(X(trainIdx,:), Y(trainIdx));

            Yhat = model.predict(X(testIdx,:));
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(testIdx)});
            Yhat = int32(Yhat);
            assert(all(ismember(unique(Yhat), unique(Y))));
            acc = nnz(Y(testIdx) == Yhat) / numel(testIdx);

            [Yhat, neiResp, dists] = model.findNearest(X(testIdx,:), K);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(testIdx)});
            Yhat = int32(Yhat);
            assert(all(ismember(unique(Yhat), unique(Y))));
            validateattributes(neiResp, {'numeric'}, ...
                {'integer', 'size',[numel(testIdx) K]});
            validateattributes(dists, {'numeric'}, ...
                {'2d', 'real', 'size',[numel(testIdx) K]});
        end

        function test_regression
            K = 5;  % number of nearest neighbors
            model = cv.KNearest();
            model.DefaultK = K;
            model.IsClassifier = false;

            model.train(TestKNearest.X, TestKNearest.YReg);
            assert(~model.isClassifier());
            assert(model.isTrained());
            Yhat = model.predict(TestKNearest.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'real' 'numel',numel(TestKNearest.YReg)});
            err = norm(Yhat - TestKNearest.YReg);
        end

        function test_data_options
            model = cv.KNearest();
            N = size(TestKNearest.X, 1);
            model.train(TestKNearest.X, TestKNearest.Y, ...
                'Data',{'Layout','Row', 'VarType','NNNC', ...
                'VarIdx',[], 'SampleIdx',[], 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});
        end

        function test_storage
            fname = tempname();
            model = cv.KNearest(TestKNearest.X, TestKNearest.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.KNearest();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.KNearest();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.KNearest(TestKNearest.X, TestKNearest.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.KNearest();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestKNearest.X);

            model3 = cv.KNearest();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestKNearest.X);
        end
    end

end

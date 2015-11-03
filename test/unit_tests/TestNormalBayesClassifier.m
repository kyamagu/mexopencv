classdef TestNormalBayesClassifier
    %TestNormalBayesClassifier
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1];
        Y = int32([ones(50,1); -ones(50,1)]);
    end

    methods (Static)
        function test_classification1
            % 2-class (binary)
            X = TestNormalBayesClassifier.X;
            Y = TestNormalBayesClassifier.Y;
            C = 2;  % number of classes

            model = cv.NormalBayesClassifier();
            model.train(X, Y);
            assert(model.isTrained());
            varcount = model.getVarCount();
            assert(isequal(varcount, size(X,2)));

            Yhat = model.predict(X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(Y)});
            assert(all(ismember(unique(Yhat), [1;-1])));
            acc = nnz(Yhat == Y) / numel(Y);

            [Yhat, prob] = model.predictProb(X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(Y)});
            assert(all(ismember(unique(Yhat), unique(Y))));
            validateattributes(prob, {'numeric'}, ...
                {'2d', 'real', 'size',[numel(Yhat) C]});  % '>=',0, '<=',1
            [~,IDX] = max(prob, [], 2);
            IDX = IDX*2 - 3;  % [1 2] -> [-1 1]
            assert(isequal(IDX, Yhat));
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
            C = numel(unique(Y));

            model = cv.NormalBayesClassifier();
            model.train(X, Y);
            [Yhat,prob] = model.predictProb(X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(Y)});
            assert(all(ismember(unique(Yhat), unique(Y))));
            validateattributes(prob, {'numeric'}, ...
                {'2d', 'real', 'size',[numel(Y) C]});

            [~,YY] = max(prob,[],2);
            YY = int32(YY);
            assert(isequal(YY, Yhat));
            acc = nnz(Y == Yhat) / numel(Y);
        end

        function test_data_options
            model = cv.NormalBayesClassifier();
            N = size(TestNormalBayesClassifier.X, 1);
            model.train(TestNormalBayesClassifier.X, TestNormalBayesClassifier.Y, ...
                'Data',{'Layout','Row', 'VarType','NNNC', ...
                'VarIdx',[], 'SampleIdx',[], 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});
        end

        function test_storage
            fname = tempname();
            model = cv.NormalBayesClassifier(...
                TestNormalBayesClassifier.X, TestNormalBayesClassifier.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.NormalBayesClassifier();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.NormalBayesClassifier();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.NormalBayesClassifier(...
                TestNormalBayesClassifier.X, TestNormalBayesClassifier.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.NormalBayesClassifier();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestNormalBayesClassifier.X);

            model3 = cv.NormalBayesClassifier();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestNormalBayesClassifier.X);
        end
    end

end

classdef TestDTrees
    %TestDTrees
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1];
        Y = int32([ones(50,1); -ones(50,1)]);
        YReg = [ones(50,1); -ones(50,1)] + randn(100,1)*0.5;
        nfields = {'value', 'classIdx', 'parent', 'left', 'right', 'defaultDir', 'split'};
        sfields = {'varIdx', 'inversed', 'quality', 'next', 'c', 'subsetOfs'};
    end

    methods (Static)
        function test_classification1
            % 2-class (binary): NNN+C
            model = cv.DTrees();
            model.MaxDepth = 10;
            model.MinSampleCount = 4;

            model.train(TestDTrees.X, TestDTrees.Y);
            assert(model.isClassifier());
            assert(model.isTrained());
            varcount = model.getVarCount();
            validateattributes(varcount, {'numeric'}, {'scalar'});
            assert(varcount == size(TestDTrees.X,2));

            Yhat = model.predict(TestDTrees.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(TestDTrees.Y)});
            Yhat = int32(Yhat);
            assert(all(ismember(unique(Yhat), unique(TestDTrees.Y))));
            acc = nnz(TestDTrees.Y == Yhat) / numel(Yhat);

            nodes = model.getNodes();
            validateattributes(nodes, {'struct'}, {'vector'});
            assert(all(ismember(TestDTrees.nfields, fieldnames(nodes))));

            splits = model.getSplits();
            validateattributes(splits, {'struct'}, {'vector'});
            assert(all(ismember(TestDTrees.sfields, fieldnames(splits))));

            roots = model.getRoots();
            validateattributes(roots, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative', '<',numel(nodes)});

            subsets = model.getSubsets();
            validateattributes(subsets, {'numeric'}, {'vector', 'integer'});
        end

        function test_classification2
            % we load data from Statistics Toolbox
            if ~license('test', 'statistics_toolbox') || isempty(ver('stats'))
                disp('SKIP');
                return;
            end

            % 3-class (multiclass): NNNN+C
            data = load('fisheriris');
            X = data.meas;
            Y = int32(grp2idx(data.species));
            trainIdx = unique([1:3:numel(Y), 2:3:numel(Y)]);
            testIdx = setdiff(1:numel(Y), trainIdx);

            model = cv.DTrees();
            model.MaxDepth = 10;
            model.MinSampleCount = 4;
            model.train(X(trainIdx,:), Y(trainIdx));

            Yhat = model.predict(X(testIdx,:));
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(testIdx)});
            Yhat = int32(Yhat);
            assert(all(ismember(unique(Yhat), unique(Y))));
            acc = nnz(Y(testIdx) == Yhat) / numel(testIdx);
        end

        function test_regression1
            % regression: NNN+N
            model = cv.DTrees();
            model.MaxDepth = 10;
            model.TruncatePrunedTree = true;
            model.train(TestDTrees.X, TestDTrees.YReg);
            assert(~model.isClassifier());
            assert(model.isTrained());
            Yhat = model.predict(TestDTrees.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'real' 'numel',numel(TestDTrees.YReg)});
            err = norm(Yhat - TestDTrees.YReg);
        end

        function test_regression2
            % regression: NCC+N
            [~,XX] = histc(TestDTrees.X, -4:4);  % discretized X
            XX(:,1) = TestDTrees.X(:,1);  % mix of numerical and categorical
            model = cv.DTrees();
            model.MaxDepth = 10;
            model.MaxCategories = 10;
            model.train(XX, TestDTrees.YReg, 'Data',{'VarType','NCCN'});
            assert(~model.isClassifier());
            assert(model.isTrained());
            Yhat = model.predict(XX);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'real' 'numel',numel(TestDTrees.YReg)});
            err = norm(Yhat - TestDTrees.YReg);
        end

        function test_data_options1
            % VarIdx/SampleIdx
            [N,d] = size(TestDTrees.X);
            model = cv.DTrees();

            model.clear();
            model.train(TestDTrees.X, TestDTrees.Y, ...
                'Data',{'VarIdx',[], 'SampleIdx',[]});
            Yhat = model.predict(TestDTrees.X);

            model.clear();
            model.train(TestDTrees.X, TestDTrees.Y, ...
                'Data',{'VarIdx',(1:d)-1, 'SampleIdx',(1:N)-1});
            Yhat = model.predict(TestDTrees.X);

            model.clear();
            model.train(TestDTrees.X, TestDTrees.Y, ...
                'Data',{'VarIdx',true(1,d), 'SampleIdx',true(1,N)});
            Yhat = model.predict(TestDTrees.X);

            model.clear();
            model.train(TestDTrees.X, TestDTrees.Y, ...
                'Data',{'VarIdx',[0,2]});
            Yhat = model.predict(TestDTrees.X(:,[0 2]+1));

            model.clear();
            model.train(TestDTrees.X, TestDTrees.Y, ...
                'Data',{'VarIdx',[true,false,true]});
            Yhat = model.predict(TestDTrees.X(:,[true,false,true]));

            %TODO: throws C++ exception
            %{
            model.clear();
            model.train(TestDTrees.X, TestDTrees.Y, ...
                'Data',{'SampleIdx',[1:20 51:70]-1});
            Yhat = model.predict(TestDTrees.X);
            %}

            %TODO: throws C++ exception
            %{
            model.clear();
            model.train(TestDTrees.X, TestDTrees.Y, ...
                'Data',{'SampleIdx',rand(N,1)>0.5});
            Yhat = model.predict(TestDTrees.X);
            %}
        end

        function test_data_options2
            model = cv.DTrees();

            N = size(TestDTrees.X, 1);
            model.train(TestDTrees.X, TestDTrees.Y, 'Data',{...
                'Layout','Row', 'VarType','NNNC', 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});

            model.clear();
            model.train(TestDTrees.X, TestDTrees.YReg, ...
                'Data',{'VarType','NNNN'});
        end

        function test_storage
            fname = tempname();
            model = cv.DTrees(TestDTrees.X, TestDTrees.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.DTrees();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.DTrees();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.DTrees(TestDTrees.X, TestDTrees.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.DTrees();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestDTrees.X);

            model3 = cv.DTrees();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestDTrees.X);
        end
    end

end

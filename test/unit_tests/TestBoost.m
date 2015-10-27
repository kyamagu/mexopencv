classdef TestBoost
    %TestBoost
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1];
        Y = int32([ones(50,1); -ones(50,1)]);
        nfields = {'value', 'classIdx', 'parent', 'left', 'right', 'defaultDir', 'split'};
        sfields = {'varIdx', 'inversed', 'quality', 'next', 'c', 'subsetOfs'};
    end

    methods (Static)
        function test_classification1
            % 2-class (binary): NNN+C
            model = cv.Boost();
            model.BoostType = 'Discrete';
            model.WeakCount = 10;

            model.train(TestBoost.X, TestBoost.Y);
            assert(model.isClassifier());
            assert(model.isTrained());
            varcount = model.getVarCount();
            validateattributes(varcount, {'numeric'}, {'scalar'});
            assert(varcount == size(TestBoost.X,2));

            Yhat = model.predict(TestBoost.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer', 'numel',numel(TestBoost.Y)});
            Yhat = int32(Yhat);
            assert(all(ismember(unique(Yhat), unique(TestBoost.Y))));
            acc = nnz(TestBoost.Y == Yhat) / numel(Yhat);

            nodes = model.getNodes();
            validateattributes(nodes, {'struct'}, {'vector'});
            assert(all(ismember(TestBoost.nfields, fieldnames(nodes))));

            splits = model.getSplits();
            validateattributes(splits, {'struct'}, {'vector'});
            assert(all(ismember(TestBoost.sfields, fieldnames(splits))));

            roots = model.getRoots();
            validateattributes(roots, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative', '<',numel(nodes)});

            subsets = model.getSubsets();
            validateattributes(subsets, {'numeric'}, {'vector', 'integer'});
        end

        %TODO: multi-class classification ?
        %TODO: regression ?

        function test_data_options1
            % VarIdx/SampleIdx
            [N,d] = size(TestBoost.X);
            model = cv.Boost();

            model.clear();
            model.train(TestBoost.X, TestBoost.Y, ...
                'Data',{'VarIdx',[], 'SampleIdx',[]});
            Yhat = model.predict(TestBoost.X);

            model.clear();
            model.train(TestBoost.X, TestBoost.Y, ...
                'Data',{'VarIdx',(1:d)-1, 'SampleIdx',(1:N)-1});
            Yhat = model.predict(TestBoost.X);

            model.clear();
            model.train(TestBoost.X, TestBoost.Y, ...
                'Data',{'VarIdx',true(1,d), 'SampleIdx',true(1,N)});
            Yhat = model.predict(TestBoost.X);

            model.clear();
            model.train(TestBoost.X, TestBoost.Y, ...
                'Data',{'VarIdx',[0,2]});
            Yhat = model.predict(TestBoost.X(:,[0 2]+1));

            model.clear();
            model.train(TestBoost.X, TestBoost.Y, ...
                'Data',{'VarIdx',[true,false,true]});
            Yhat = model.predict(TestBoost.X(:,[true,false,true]));

            %TODO: throws C++ exception
            %{
            model.clear();
            model.train(TestBoost.X, TestBoost.Y, ...
                'Data',{'SampleIdx',[1:20 51:70]-1});
            Yhat = model.predict(TestBoost.X);
            %}

            %TODO: throws C++ exception
            %{
            model.clear();
            model.train(TestBoost.X, TestBoost.Y, ...
                'Data',{'SampleIdx',rand(N,1)>0.5});
            Yhat = model.predict(TestBoost.X);
            %}
        end

        function test_data_options2
            model = cv.Boost();

            N = size(TestBoost.X, 1);
            model.train(TestBoost.X, TestBoost.Y, 'Data',{...
                'Layout','Row', 'VarType','NNNC', 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});
        end

        function test_storage
            fname = tempname();
            model = cv.Boost(TestBoost.X, TestBoost.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.Boost();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.Boost();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.Boost(TestBoost.X, TestBoost.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.Boost();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestBoost.X);

            model3 = cv.Boost();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestBoost.X);
        end
    end

end

classdef TestSVMSGD
    %TestSVMSGD

    properties (Constant)
        X = [randn(10,3)+1; randn(10,3)-1];
        Y = double([ones(10,1); -ones(10,1)]);
    end

    methods (Static)
        function test_classification1
            % 2-class (binary)
            model = cv.SVMSGD();
            model.SvmsgdType = 'ASGD';
            model.TermCriteria.maxCount = 100000;
            model.TermCriteria.epsilon = 1e-5;

            assert(~model.isTrained());
            success = model.train(TestSVMSGD.X, TestSVMSGD.Y);
            validateattributes(success, {'logical'}, {'scalar'});
            assert(model.isTrained());
            assert(model.isClassifier());
            varcount = model.getVarCount();
            validateattributes(varcount, {'numeric'}, {'scalar'});
            assert(varcount == size(TestSVMSGD.X,2));

            weights = model.getWeights();
            validateattributes(weights, {'numeric'}, ...
                {'vector', 'numel',size(TestSVMSGD.X,2)});
            shift = model.getShift();
            validateattributes(shift, {'numeric'}, {'scalar'});

            Yhat = model.predict(TestSVMSGD.X);
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer' 'numel',numel(TestSVMSGD.Y)});
            assert(all(ismember(unique(Yhat), [-1 1])));
            acc = nnz(Yhat == TestSVMSGD.Y) / numel(TestSVMSGD.Y);
        end

        function test_classification2
            % we load data from Statistics Toolbox
            if mexopencv.isOctave() || ~mexopencv.require('stats')
                error('mexopencv:testskip', 'toolbox');
            end

            % 3-class (multiclass)
            data = load('fisheriris');
            X = data.meas;
            Y = grp2idx(data.species);
            trainIdx = unique([1:3:numel(Y), 2:3:numel(Y)]);
            testIdx = setdiff(1:numel(Y), trainIdx);

            model = cv.SVMSGD();
            model.train(X(trainIdx,:), Y(trainIdx,:));

            Yhat = model.predict(X(testIdx,:));
            validateattributes(Yhat, {'numeric'}, ...
                {'vector', 'integer' 'numel',numel(testIdx)});
            assert(all(ismember(unique(Yhat), unique(Y))));
            acc = nnz(Yhat == Y(testIdx)) / numel(testIdx);
        end

        function test_data_options1
            % VarIdx/SampleIdx
            [N,d] = size(TestSVMSGD.X);
            model = cv.SVMSGD();

            model.clear();
            model.train(TestSVMSGD.X, TestSVMSGD.Y, ...
                'Data',{'VarIdx',[], 'SampleIdx',[]});
            Yhat = model.predict(TestSVMSGD.X);

            model.clear();
            model.train(TestSVMSGD.X, TestSVMSGD.Y, ...
                'Data',{'VarIdx',(1:d)-1, 'SampleIdx',(1:N)-1});
            Yhat = model.predict(TestSVMSGD.X);

            model.clear();
            model.train(TestSVMSGD.X, TestSVMSGD.Y, ...
                'Data',{'VarIdx',true(1,d), 'SampleIdx',true(1,N)});
            Yhat = model.predict(TestSVMSGD.X);

            model.clear();
            model.train(TestSVMSGD.X, TestSVMSGD.Y, ...
                'Data',{'VarIdx',[0,2]});
            Yhat = model.predict(TestSVMSGD.X(:,[0 2]+1));

            model.clear();
            model.train(TestSVMSGD.X, TestSVMSGD.Y, ...
                'Data',{'VarIdx',[true,false,true]});
            Yhat = model.predict(TestSVMSGD.X(:,[true,false,true]));

            %TODO: might throw C++ exception (not enough samples?)
            if false
                model.clear();
                model.train(TestSVMSGD.X, TestSVMSGD.Y, ...
                    'Data',{'SampleIdx',[1:3 6:8]-1});
                Yhat = model.predict(TestSVMSGD.X);

                model.clear();
                model.train(TestSVMSGD.X, TestSVMSGD.Y, ...
                    'Data',{'SampleIdx',rand(N,1)>0.5});
                Yhat = model.predict(TestSVMSGD.X);
            end
        end

        function test_data_options2
            model = cv.SVMSGD();

            N = size(TestSVMSGD.X, 1);
            model.train(TestSVMSGD.X, TestSVMSGD.Y, 'Data',{...
                'Layout','Row', 'VarType','NNNC', 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});
        end

        function test_storage
            fname = tempname();
            model = cv.SVMSGD(TestSVMSGD.X, TestSVMSGD.Y);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.SVMSGD();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.SVMSGD();
            model2.load([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.SVMSGD(TestSVMSGD.X, TestSVMSGD.Y);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.SVMSGD();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestSVMSGD.X);

            model3 = cv.SVMSGD();
            model3.load(strYML, 'FromString',true);
            Yhat = model3.predict(TestSVMSGD.X);
        end
    end

end

classdef TestEM
    %TestEM
    properties (Constant)
        X = [randn(50,3)+1; randn(50,3)-1; randn(50,3)-2];
    end

    methods (Static)
        function test_clustering
            [N,d] = size(TestEM.X);
            C = 3;
            model = cv.EM();
            model.ClustersNumber = C;
            model.CovarianceMatrixType = 'Diagonal';
            model.TermCriteria.maxCount = 100;
            model.TermCriteria.epsilon = 1e-6;

            model.train(TestEM.X);
            assert(model.isTrained());

            [LL, IDX, probs] = model.trainEM(TestEM.X);
            validateattributes(LL, {'numeric'}, {'vector', 'numel',N});
            validateattributes(IDX, {'numeric'}, ...
                {'vector', 'integer', '<',C, 'numel',N});
            validateattributes(probs, {'numeric'}, ...
                {'size',[N C], 'real', '>=',0, '<=',1});

            weights = model.getWeights();
            validateattributes(weights, {'numeric'}, {'vector', 'numel',C});

            means = model.getMeans();
            validateattributes(means, {'numeric'}, {'size',[C d]});

            covs = model.getCovs();
            validateattributes(covs, {'cell'}, {'vector'});
            if ~mexopencv.isOctave()  %TODO: https://savannah.gnu.org/bugs/index.php?46328
                cellfun(@(covar) validateattributes(covar, {'numeric'}, ...
                    {'square', 'diag', 'size',[d d]}), covs);
            end

            [LL, IDX, probs] = model.trainE(TestEM.X, means);
            [LL, IDX, probs] = model.trainE(TestEM.X, means, 'Covs0',covs);
            [LL, IDX, probs] = model.trainE(TestEM.X, means, ...
                'Covs0',covs, 'Weights0',weights);

            [LL, IDX, probs] = model.trainM(TestEM.X, probs);

            probs = model.predict(TestEM.X);
            validateattributes(probs, {'numeric'}, ...
                {'size',[N C], 'real', '>=',0, '<=',1});

            [LL, IDX, probs] = model.predict2(TestEM.X);
            validateattributes(LL, {'numeric'}, {'vector', 'numel',N});
            validateattributes(IDX, {'numeric'}, ...
                {'vector', 'integer', '<',C, 'numel',N});
            validateattributes(probs, {'numeric'}, ...
                {'size',[N C], 'real', '>=',0, '<=',1});
        end

        function test_data_options
            model = cv.EM();
            N = size(TestEM.X, 1);
            model.train(TestEM.X, 'Data',{'Layout','Row', 'VarType','NNN', ...
                'VarIdx',[], 'SampleIdx',[], 'SampleWeights',ones(N,1), ...
                'TrainTestSplitRatio',1/3, 'TrainTestSplitShuffle',true});
        end

        function test_storage
            fname = tempname();
            model = cv.EM();
            model.train(TestEM.X);

            model.save([fname '.xml']);
            cleanObj = onCleanup(@() delete([fname '.xml']));
            model1 = cv.EM();
            model1.load([fname '.xml']);
            %isequal(model, model1)

            model.save([fname '.yaml']);
            cleanObj = onCleanup(@() delete([fname '.yaml']));
            model2 = cv.EM([fname '.yaml']);
            %isequal(model, model2)

            model1.clear();
            model2.clear();
        end

        function test_serialization
            model = cv.EM();
            model.train(TestEM.X);
            strXML = model.save('.xml');
            strYML = model.save('.yml');

            model2 = cv.EM();
            model2.load(strXML, 'FromString',true);
            Yhat = model2.predict(TestEM.X);

            model3 = cv.EM(strYML, 'FromString',true);
            Yhat = model3.predict(TestEM.X);
        end
    end

end

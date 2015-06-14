classdef TestNormalBayesClassifier
    %TestNormalBayesClassifier
    properties (Constant)
    end

    methods (Static)
        function test_1
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = int32([ones(50,1);-ones(50,1)]);
            classifier = cv.NormalBayesClassifier();
            classifier.train(X,Y);
            Yhat = classifier.predict(X);
            assert(isvector(Yhat) && numel(Yhat)==100);
        end

        function test_2
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = int32([ones(50,1);-ones(50,1)]);
            classifier = cv.NormalBayesClassifier();
            classifier.train(X,Y);
            [Yhat,prob] = classifier.predictProb(X);
            assert(isvector(Yhat) && numel(Yhat)==100);
            assert(isequal(size(prob),[100 2]));
        end

        function test_3
            % requires Statistics Toolbox
            if ~license('test','statistics_toolbox'), return; end

            data = load('fisheriris');
            X = data.meas;
            Y = int32(grp2idx(data.species));
            classifier = cv.NormalBayesClassifier();
            classifier.train(X,Y);
            [Yhat,prob] = classifier.predictProb(X);

            [~,YY] = max(prob,[],2);
            assert(isequal(YY,Yhat))
            err = nnz(double(Y)-double(Yhat)) / numel(Y);
        end
    end

end

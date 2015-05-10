classdef TestANN_MLP
    %TestANN_MLP
    properties (Constant)
    end

    methods (Static)
        function test_1
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = [ones(50,1);-ones(50,1)];
            classifier = cv.ANN_MLP();
            classifier.LayerSizes = [3,1];
            classifier.train(X,Y);
            Yhat = classifier.predict(X);
            layers =   classifier.LayerSizes;
            w0 =       classifier.getWeights(0);
            w1 =       classifier.getWeights(1);
        end
    end

end

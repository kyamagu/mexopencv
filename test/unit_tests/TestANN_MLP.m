classdef TestANN_MLP
    %TestANN_MLP
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            X = [randn(50,3)+1;randn(50,3)-1];
            Y = [ones(50,1);-ones(50,1)];
            classifier = cv.ANN_MLP([3,1]);
            classifier.train(X,Y);
            Yhat = classifier.predict(X);
            n_layers = classifier.get_layer_count();
            layers =   classifier.get_layer_sizes();
            w0 =       classifier.get_weights(0);
            w1 =       classifier.get_weights(1);
        end
    end
    
end


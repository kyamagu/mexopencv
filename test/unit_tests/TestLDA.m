classdef TestLDA
    %TESTLDA
    properties (Constant)
    end

    methods (Static)
        function test_1
            X = randn(100,5);
            labels = randi([1 3], [100 1]);
            lda = cv.LDA();
            lda.compute(X, labels);
            evals = lda.eigenvalues();
            evecs = lda.eigenvectors();
        end
    end

end

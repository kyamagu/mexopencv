classdef TestPCA
    %TestPCA
    properties (Constant)
    end

    methods (Static)
        function test_1
            Xtrain = randn(100,10);
            Xtest  = randn(100,10);
            pca = cv.PCA(Xtrain, 'MaxComponents', 3);
            Y = pca.project(Xtest);
            Xapprox = pca.backProject(Y);
        end

        function test_2
            Xtrain = randn(100,10);
            pca = cv.PCA(Xtrain, 'MaxComponents', 3);
            S = pca.struct;
            pca2 = cv.PCA(S);
            assert(all(pca.mean(:)==pca2.mean(:)));
        end

        function test_3
            fname = [tempname '.xml'];
            cleanObj = onCleanup(@() delete(fname));

            X = randn(100,10);
            pca = cv.PCA();
            pca.compute(X, 'RetainedVariance',0.8)
            pca.write(fname)

            pca2 = cv.PCA();
            pca2.read(fname)

            assert(norm(pca.mean - pca2.mean) < 1e-6)
        end
    end

end

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
    end
    
end


classdef TestPCA
    %TestPCA

    methods (Static)
        function test_1
            Xtrain = randn(100,10);
            Xtest  = randn(100,10);
            pca = cv.PCA(Xtrain, 'MaxComponents',3);
            Y = pca.project(Xtest);
            Xapprox = pca.backProject(Y);
            assert(isvector(pca.mean) && numel(pca.mean) == 10);
            assert(isvector(pca.eigenvalues) && numel(pca.eigenvalues) == 3);
            assert(ismatrix(pca.eigenvectors) && isequal(size(pca.eigenvectors), [3 10]));
            assert(isequal(size(Y), [size(Xtest,1) 3]))
            assert(isequal(size(Xtest), size(Xapprox)));
        end

        function test_2
            Xtrain = randn(100,10);
            pca = cv.PCA(Xtrain, 'MaxComponents',3);
            S = struct(pca);
            pca2 = cv.PCA(S);
            assert(isequal(pca.mean(:),pca2.mean(:)));
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

        function test_4
            if mexopencv.isOctave()
                % TODO: load/save of objects to MAT-file in Octave
                disp('SKIP');
                return
            end

            fname = [tempname '.mat'];
            cleanObj = onCleanup(@() delete(fname));

            pca = cv.PCA(rand(100,5));
            save(fname, 'pca');

            L = load(fname, 'pca');
            pca2 = L.pca;
            assert(isequal(struct(pca), struct(pca2)));
        end
    end

end

classdef TestLDA
    %TestLDA

    methods (Static)
        function test_1
            % data
            X = [randn(50,5)-1; randn(50,5)+1];
            labels = [ones(50,1)*1; ones(50,1)*2];
            [N,d] = size(X);

            % LDA
            lda = cv.LDA();
            lda.compute(X, labels);
            evals = lda.eigenvalues;
            evecs = lda.eigenvectors;
            ncomponents = numel(evals);

            assert(isvector(evals) && ismatrix(evecs));
            assert(isequal(size(evecs), [d ncomponents]))

            % project/reconstruct
            if ncomponents == 1
                % avoid edge case when only 1 component was chosen
                return
            end
            A = randn(40,d);
            Z = lda.project(A);
            AA = lda.reconstruct(Z);
            assert(isequal(size(Z), [size(A,1) ncomponents]))
            assert(isequal(size(AA), size(A)));
        end

        function test_2
            X = randn(50,4);
            labels = randi([1 3], [50 1]);
            lda = cv.LDA('NumComponents',2);
            lda.compute(X, labels)
            assert(numel(lda.eigenvalues) == 2);
            assert(size(lda.eigenvectors,2) == 2);
        end

        function test_3
            X = randn(50,4);
            k = 3;
            mn = mean(X);
            [V,~] = eig(cov(bsxfun(@minus,X,mn)));

            P = cv.LDA.subspaceProject(V(:,1:k), mn, X);
            validateattributes(P, {'double'}, {'size',[50 k]});

            R = cv.LDA.subspaceReconstruct(V(:,1:k), mn, P);
            validateattributes(R, {'double'}, {'size',[50 4]});
        end

        function test_error_1
            try
                cv.LDA('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

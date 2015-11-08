classdef TestLDA
    %TESTLDA

    methods (Static)
        function test_1
            % data
            X = [randn(100,5)-1; randn(100,5)+1];
            labels = [ones(100,1)*1; ones(100,1)*2];
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
            A = randn(50,d);
            Z = lda.project(A);
            AA = lda.reconstruct(Z);
            assert(isequal(size(Z), [size(A,1) ncomponents]))
            assert(isequal(size(AA), size(A)));
        end

        function test_2
            X = randn(100,4);
            labels = randi([1 3], [100 1]);
            lda = cv.LDA('NumComponents',2);
            lda.compute(X, labels)
            assert(numel(lda.eigenvalues) == 2);
            assert(size(lda.eigenvectors,2) == 2);
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

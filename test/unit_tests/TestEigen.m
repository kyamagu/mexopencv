classdef TestEigen

    methods (Static)
        function test_1
            A = randn(5); A = A.'*A;
            evals = cv.eigen(A);
            [evals,evecs,b] = cv.eigen(A);
        end

        function test_compare_against_eig
            A = gallery('lehmer',4);
            [evals,evecs] = cv.eigen(A);

            % match orientation, order, and sign
            [V,D] = eig(A);
            [D,ord] = sort(diag(D), 'descend');
            V = V(:,ord).';
            idx = (sign(evecs(:,1)) ~= sign(V(:,1)));
            V(idx,:) = -1 * V(idx,:);

            % compare
            assert(norm(D - evals) < 1e-6);
            assert(norm(V - evecs) < 1e-6);
        end

        function test_error_1
            try
                cv.eigen();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

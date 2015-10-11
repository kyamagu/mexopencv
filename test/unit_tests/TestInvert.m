classdef TestInvert
    %TestInvert

    methods (Static)
        function test_nonsingular
            A = randn(20);
            [B,status] = cv.invert(A);
            assert(isscalar(status));
            assert(ismatrix(B) && isequal(size(B),size(A)));
            assert(norm(A*B - eye(20)) < 1e-9);
        end

        function test_singular
            A = [1 0 0; -2 0 0; 4 6 1];
            %B = inv(A);
            [B,status] = cv.invert(A);
        end

        function test_close_to_singular
            A = 5*eye(5) - ones(5);
            %B = inv(A);
            [B,status] = cv.invert(A);
        end

        function test_hilbert
            A = hilb(7);
            B = inv(A);
            B = cv.invert(A, 'Method','LU');
            B = cv.invert(A, 'Method','Cholesky');
        end

        function test_pseudoinv
            A = magic(8); A = A(:,1:6);
            B = pinv(A); c = 1./cond(A);
            [B,c] = cv.invert(A, 'Method','SVD');
        end

        function test_error_1
            try
                cv.invert();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

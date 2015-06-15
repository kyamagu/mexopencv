classdef TestSolve

    methods (Static)
        function test_1
            A = magic(5);
            b = ones(5,1);
            x = A\b;
            if ~mexopencv.isOctave()
                %TODO: http://savannah.gnu.org/bugs/?45212
                x = linsolve(A, b);
            end
            [x,ret] = cv.solve(A, b);
            assert(isscalar(ret) && islogical(ret));
            assert(isvector(x));
            norm(A*x - b);
        end

        function test_2
            A = magic(5);
            b = [ones(5,1) 2*ones(5,1)];
            x = cv.solve(A, b);
            assert(ismatrix(x));
            norm(A*x - b);
        end

        function test_isnormal
            A = magic(5);
            b = ones(5,1);
            x = cv.solve(A, b, 'IsNormal',true);
        end

        function test_nonsquare
            A = randn(10,4);
            b = ones(10,1);
            x = cv.solve(A, b, 'Method','QR');
        end

        function test_error_1
            try
                cv.solve();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

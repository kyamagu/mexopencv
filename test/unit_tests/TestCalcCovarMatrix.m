classdef TestCalcCovarMatrix
    %TestCalcCovarMatrix

    methods (Static)
        function test_1
            X = randn(100,4);
            [c,m] = cv.calcCovarMatrix(X);
            [c,m] = cv.calcCovarMatrix(X, 'Scale',true);
        end

        function test_2
            X = randn(100,4);
            [c,m] = cv.calcCovarMatrix(X.', 'Cols',true);
        end

        function test_3
            X = randn(100,4);
            [c,m] = cv.calcCovarMatrix(X, 'Mean',mean(X));
        end

        function test_error_1
            try
                cv.calcCovarMatrix();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

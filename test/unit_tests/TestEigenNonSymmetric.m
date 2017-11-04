classdef TestEigenNonSymmetric
    %TestEigenNonSymmetric

    methods (Static)
        function test_1
            A = randn(5);
            evals = cv.eigenNonSymmetric(A);
            [evals,evecs] = cv.eigenNonSymmetric(A);
        end

        function test_error_argnum
            try
                cv.eigenNonSymmetric();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

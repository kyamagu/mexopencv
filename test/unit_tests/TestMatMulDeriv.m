classdef TestMatMulDeriv
    %TestMatMulDeriv
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            A = randn(3,3);
            B = randn(3,3);
            [dABdA,dABdB] = cv.matMulDeriv(A,B);
        end
        
        function test_error_1
            try
                cv.matMulDeriv();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


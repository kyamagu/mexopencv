classdef TestGetGaussianKernel
    %TestScharr
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            result = cv.getGaussianKernel();
        end
        
        function test_error_1
            try
                cv.getGaussianKernel(1);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


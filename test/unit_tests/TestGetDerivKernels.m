classdef TestGetDerivKernels
    %TestScharr
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            result = cv.getDerivKernels();
        end
        
        function test_error_1
            try
                cv.getDerivKernels(1);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


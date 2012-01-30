classdef TestSolvePnPRansac
    %TestSolvePnP
    properties (Constant)
    end
    
    methods (Static)        
        function test_error_1
            try
                cv.solvePnPRansac();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


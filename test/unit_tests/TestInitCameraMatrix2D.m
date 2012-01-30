classdef TestInitCameraMatrix2D
    %TestInitCameraMatrix2D
    properties (Constant)
    end
    
    methods (Static)
        
        function test_error_1
            try
                cv.initCameraMatrix2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


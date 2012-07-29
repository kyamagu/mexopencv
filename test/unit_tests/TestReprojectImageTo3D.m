classdef TestReprojectImageTo3D
    %TestReprojectImageTo3D
    properties (Constant)
    end
    
    methods (Static)        
        function test_error_1
            try
                cv.reprojectImageTo3D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


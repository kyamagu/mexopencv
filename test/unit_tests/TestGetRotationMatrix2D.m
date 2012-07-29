classdef TestGetRotationMatrix2D
    %TestGetRotationMatrix2D
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            center = [0,0];
            angle = 180;
            scale = 1.0;
            ref = [-1,0,0;0,-1,0];
            t = cv.getRotationMatrix2D(center, angle, scale);
            assert(all(abs(t(:)-ref(:))<1e-5));
        end
        
        function test_error_1
            try
                cv.getRotationMatrix2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


classdef TestUndistortPoints
    %TestUndistortPoints
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            pts = [0,0; 0,1; 3,4; 5,6];
            pts = shiftdim(pts,-1);
            result = cv.undistortPoints(pts, eye(3), []);
            assert(all(result(:)==pts(:)));
        end
        
        function test_error_1
            try
                cv.undistortPoints();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


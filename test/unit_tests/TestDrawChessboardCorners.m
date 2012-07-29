classdef TestDrawChessboardCorners
    %TestDrawChessboardCorners
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = TestFindChessboardCorners.img;
            result = cv.findChessboardCorners(im, [9,6]);
            im = cv.drawChessboardCorners(im, [9,6], result);
        end
        
        function test_error_1
            try
                cv.drawChessboardCorners();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


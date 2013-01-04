classdef TestDrawChessboardCorners
    %TestDrawChessboardCorners
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
    end
    
    methods (Static)
        function test_1
            im = TestDrawChessboardCorners.img;
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


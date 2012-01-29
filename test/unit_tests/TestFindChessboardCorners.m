classdef TestFindChessboardCorners
    %TestFindChessboardCorners
    properties (Constant)
        img = imread(fullfile('test','left01.jpg'));
    end
    
    methods (Static)
        function test_1
        	im = TestFindChessboardCorners.img;
            result = cv.findChessboardCorners(im, [9,6]);
        end
        
        function test_error_1
            try
                cv.findChessboardCorners();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


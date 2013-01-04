classdef TestFindChessboardCorners
    %TestFindChessboardCorners
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
    end
    
    methods (Static)
        function test_1
            result = cv.findChessboardCorners(TestFindChessboardCorners.img, [9,6]);
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


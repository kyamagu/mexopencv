classdef TestHoughLines
    %TestHoughLines
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end
    
    methods (Static)
        function test_1
            result = cv.HoughLines(TestHoughLines.img);
        end
        
        function test_error_1
            try
                cv.HoughLines();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


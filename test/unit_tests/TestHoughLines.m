classdef TestHoughLines
    %TestHoughLines
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = rgb2gray(imread([TestHoughLines.path,filesep,'img001.jpg']))
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


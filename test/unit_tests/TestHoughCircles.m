classdef TestHoughCircles
    %TestHoughCircles
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = rgb2gray(imread([TestHoughCircles.path,filesep,'img001.jpg']))
    end
    
    methods (Static)
        function test_1
            result = cv.HoughCircles(TestHoughCircles.img);
        end
        
        function test_error_1
            try
                cv.HoughCircles();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


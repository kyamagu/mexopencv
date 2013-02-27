classdef TestHoughLinesP
    %TestHoughLinesP
    properties (Constant)
        img = rgb2gray(imread(fullfile(cv_root(),'test','img001.jpg')));
    end
    
    methods (Static)
        function test_1
            result = cv.HoughLinesP(TestHoughLinesP.img);
        end
        
        function test_error_1
            try
                cv.HoughLinesP();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


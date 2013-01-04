classdef TestHoughCircles
    %TestHoughCircles
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
            im = imresize(im,0.5);
            result = cv.HoughCircles(im);
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


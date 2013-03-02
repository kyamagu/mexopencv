classdef TestCornerHarris
    %TestCornerHarris
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end
    
    methods (Static)
        function test_1
            result = cv.cornerHarris(TestCornerHarris.img);
        end
        
        function test_error_1
            try
                cv.cornerHarris();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


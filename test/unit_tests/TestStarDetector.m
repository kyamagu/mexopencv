classdef TestStarDetector
    %TestStarDetector
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end
    
    methods (Static)
        function test_1
            kpts = cv.StarDetector(TestStarDetector.img);
        end
        
        function test_error_1
            try
                cv.StarDetector();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


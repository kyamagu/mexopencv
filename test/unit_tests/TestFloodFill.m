classdef TestFloodFill
    %TestFloodFill
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            im = rgb2gray(TestFloodFill.img);
            seed = [100,100];
            value = 255;
            rslt = cv.floodFill(im, seed, value);
        end
        
        function test_error_1
            try
                cv.floodFill();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


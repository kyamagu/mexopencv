classdef TestFloodFill
    %TestFloodFill
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = imread([TestFloodFill.path,filesep,'img001.jpg'])
    end
    
    methods (Static)
        function test_1
            im = rgb2gray(TestFloodFill.img);
            seed = [100,100];
            value = 255;
            rslt = floodFill(im, seed, value);
        end
        
        function test_error_1
            try
                floodFill();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


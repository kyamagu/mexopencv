classdef TestFAST
    %TestFAST
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = imread([TestFAST.path,filesep,'img001.jpg'])
    end
    
    methods (Static)
        function test_1
        	im = rgb2gray(TestFAST.img);
            result = cv.FAST(im);
        end
        
        function test_error_1
            try
                cv.FAST();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


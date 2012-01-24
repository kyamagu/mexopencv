classdef TestCornerMinEigenVal
    %TestCornerMinEigenVal
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        img = rgb2gray(imread([TestCornerMinEigenVal.path,filesep,'img001.jpg']))
    end
    
    methods (Static)
        function test_1
            result = cv.cornerMinEigenVal(TestCornerMinEigenVal.img);
        end
        
        function test_error_1
            try
                cv.cornerMinEigenVal();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


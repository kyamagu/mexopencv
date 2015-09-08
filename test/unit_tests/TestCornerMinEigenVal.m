classdef TestCornerMinEigenVal
    %TestCornerMinEigenVal
    properties (Constant)
        img = rgb2gray(imread(fullfile(mexopencv.root(),'test','img001.jpg')));
    end

    methods (Static)
        function test_1
            result = cv.cornerMinEigenVal(TestCornerMinEigenVal.img);
            validateattributes(result, {'single'}, ...
                {'size',size(TestCornerMinEigenVal.img)});
        end

        function test_2
            result = cv.cornerMinEigenVal(im2single(TestCornerMinEigenVal.img));
            validateattributes(result, {'single'}, ...
                {'size',size(TestCornerMinEigenVal.img)});
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

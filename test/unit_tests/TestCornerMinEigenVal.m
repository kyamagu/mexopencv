classdef TestCornerMinEigenVal
    %TestCornerMinEigenVal
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestCornerMinEigenVal.im, 'Grayscale',true);
            result = cv.cornerMinEigenVal(img);
            validateattributes(result, {'single'}, {'size',size(img)});
        end

        function test_2
            img = cv.imread(TestCornerMinEigenVal.im, 'Grayscale',true);
            result = cv.cornerMinEigenVal(single(img)/255);
            validateattributes(result, {'single'}, {'size',size(img)});
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

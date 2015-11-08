classdef TestCornerHarris
    %TestCornerHarris
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_8bit
            img = cv.imread(TestCornerHarris.im, 'Grayscale',true);
            result = cv.cornerHarris(img);
            validateattributes(result, {'single'}, {'size',size(img)});
        end

        function test_float
            img = cv.imread(TestCornerHarris.im, 'Grayscale',true);
            result = cv.cornerHarris(single(img)/255);
            validateattributes(result, {'single'}, {'size',size(img)});
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

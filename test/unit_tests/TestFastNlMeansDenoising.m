classdef TestFastNlMeansDenoising
    %TestFastNlMeansDenoising
    properties (Constant)
        im = rgb2gray(imread(fullfile(mexopencv.root(),'test','lena.jpg')));
    end

    methods (Static)
        function test_1
            img = imnoise(TestFastNlMeansDenoising.im, 'gaussian');
            out = cv.fastNlMeansDenoising(img, 'H',20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.fastNlMeansDenoising();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

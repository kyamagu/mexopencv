classdef TestFastNlMeansDenoising
    %TestFastNlMeansDenoising
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestFastNlMeansDenoising.im, 'Grayscale',true);
            out = cv.fastNlMeansDenoising(img, 'H',20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            % we use IMNOISE from Image Processing Toolbox
            if ~mexopencv.require('images')
                disp('SKIP');
                return;
            end

            img = cv.imread(TestFastNlMeansDenoising.im, 'Grayscale',true);
            img = imnoise(img, 'gaussian');
            out = cv.fastNlMeansDenoising(img, 'H',20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_3
            % we use IMNOISE from Image Processing Toolbox
            if ~mexopencv.require('images')
                disp('SKIP');
                return;
            end

            img = cv.imread(TestFastNlMeansDenoising.im, 'Grayscale',true);
            img = imnoise(img, 'gaussian');
            img = im2uint16(img);
            out = cv.fastNlMeansDenoising(img, 'H',5000, 'NormType','L1');
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

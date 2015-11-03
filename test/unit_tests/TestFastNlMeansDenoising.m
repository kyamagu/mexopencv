classdef TestFastNlMeansDenoising
    %TestFastNlMeansDenoising
    properties (Constant)
        im = rgb2gray(imread(fullfile(mexopencv.root(),'test','lena.jpg')));
    end

    methods (Static)
        function test_1
            img = TestFastNlMeansDenoising.im;
            out = cv.fastNlMeansDenoising(TestFastNlMeansDenoising.im, 'H',20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            % requires Image Processing Toolbox
            if mexopencv.isOctave()
                img_lic = 'image';
                img_ver = img_lic;
            else
                img_lic = 'image_toolbox';
                img_ver = 'images';
            end
            if ~license('test', img_lic) || isempty(ver(img_ver))
                disp('SKIP');
                return;
            end

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

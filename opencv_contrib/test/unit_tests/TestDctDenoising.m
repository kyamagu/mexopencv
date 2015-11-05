classdef TestDctDenoising
    %TestDctDenoising
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_gray
            img = cv.imread(TestDctDenoising.im, 'Grayscale',true);
            img = cv.resize(img, 0.4, 0.4);
            dst = cv.dctDenoising(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_rgb1
            img = imread(TestDctDenoising.im);
            img = cv.resize(img, 0.4, 0.4);
            dst = cv.dctDenoising(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_rgb2
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

            % CV_8U
            img = imread(TestDctDenoising.im);
            img = cv.resize(img, 0.4, 0.4);
            img = imnoise(img, 'gaussian', 0, 0.01);
            dst = cv.dctDenoising(img, 'Sigma',sqrt(0.01)*255, 'BlockSize',16);
            validateattributes(dst, {class(img)}, {'size',size(img)});

            % CV_32F
            img = im2single(imread(TestDctDenoising.im));
            img = cv.resize(img, 0.4, 0.4);
            img = imnoise(img, 'gaussian', 0, 0.01);
            dst = cv.dctDenoising(img, 'Sigma',sqrt(0.01), 'BlockSize',16);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.dctDenoising();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

classdef TestDenoise_TVL1
    %TestDenoise_TVL1
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestDenoise_TVL1.im, 'Grayscale',true);
            images = repmat({img},1,5);
            out = cv.denoise_TVL1(images, 'Lambda',1.0, 'NIters',30);
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

            img = cv.imread(TestDenoise_TVL1.im, 'Grayscale',true);
            images = cell(1,5);
            for i=1:numel(images)
                images{i} = imnoise(img, 'gaussian');
            end
            out = cv.denoise_TVL1(images, 'Lambda',1.0, 'NIters',30);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_3
            img = cv.imread(TestDenoise_TVL1.im, 'Grayscale',true);
            images = cell(1,5);
            for i=1:numel(images)
                images{i} = make_noisy(img, 20, 0.02);
            end
            out = cv.denoise_TVL1(images);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_4
            img = cv.imread(TestDenoise_TVL1.im, 'Grayscale',true);
            images = cell(1,5);
            for i=1:numel(images)
                images{i} = make_spotty(img);
            end
            out = cv.denoise_TVL1(images);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.denoise_TVL1();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

% https://github.com/Itseez/opencv/blob/master/modules/photo/test/test_denoise_tvl1.cpp

function noisy = make_noisy(img, sigma, pepper_salt_ratio)
    noise = uint8(randn(size(img))*sigma + 128);
    noisy = uint8(double(img) + double(noise) - 128);
    noise = uint8((randn(size(noise))*2)*255);
    mask = randi([0 round(1/pepper_salt_ratio)], size(img), 'uint8');
    mask(:,1:fix(end/2)) = 1;
    noise(mask~=0) = 128;
    noisy = uint8(double(noisy) + double(noise) - 128);
end

function img = make_spotty(img, r, n)
    if nargin < 3, n = 1000; end
    if nargin < 2, r = 3; end
    for i=1:n
        x = randi([1 size(img,2)-r-1]);
        y = randi([1 size(img,1)-r-1]);
        img(x:x+r, y:y+r) = randi([0 1])*255;
    end
end

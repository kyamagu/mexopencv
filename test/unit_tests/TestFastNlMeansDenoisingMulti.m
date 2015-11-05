classdef TestFastNlMeansDenoisingMulti
    %TestFastNlMeansDenoisingMulti
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestFastNlMeansDenoisingMulti.im, 'Grayscale',true);
            imgs = repmat({img},1,5);
            out = cv.fastNlMeansDenoisingMulti(imgs, 2, 3, 'H',20);
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

            img = cv.imread(TestFastNlMeansDenoisingMulti.im, 'Grayscale',true);
            imgs = cell(1,5);
            for i=1:numel(imgs)
                imgs{i} = imnoise(img, 'gaussian');
            end
            out = cv.fastNlMeansDenoisingMulti(imgs, 2, 3, 'H',20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_3
            files = dir(fullfile(mexopencv.root(),'test','left*.jpg'));
            imgs = cell(1, numel(files));
            for i=1:numel(files)
                imgs{i} = imread(fullfile(mexopencv.root(),'test',files(i).name));
            end
            out = cv.fastNlMeansDenoisingMulti(imgs, 6-1, 7);
            validateattributes(out, {class(imgs{1})}, {'size',size(imgs{1})});
        end

        function test_error_1
            try
                cv.fastNlMeansDenoisingMulti();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

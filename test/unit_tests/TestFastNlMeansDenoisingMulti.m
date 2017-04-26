classdef TestFastNlMeansDenoisingMulti
    %TestFastNlMeansDenoisingMulti

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestFastNlMeansDenoisingMulti.im, ...
                'Grayscale',true, 'ReduceScale',2);
            imgs = repmat({img},1,5);
            out = cv.fastNlMeansDenoisingMulti(imgs, 2, 3, 'H',20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            % we use IMNOISE Image Processing Toolbox
            if ~mexopencv.require('images')
                error('mexopencv:testskip', 'toolbox');
            end

            img = cv.imread(TestFastNlMeansDenoisingMulti.im, ...
                'Grayscale',true, 'ReduceScale',2);
            imgs = cell(1,5);
            for i=1:numel(imgs)
                imgs{i} = imnoise(img, 'gaussian');
            end
            out = cv.fastNlMeansDenoisingMulti(imgs, 2, 3, 'H',20);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_3
            files = dir(fullfile(mexopencv.root(),'test','left0*.jpg'));
            imgs = cell(1, numel(files));
            for i=1:numel(files)
                imgs{i} = cv.imread(fullfile(mexopencv.root(),'test',files(i).name), ...
                    'Grayscale',true, 'ReduceScale',2);
            end
            out = cv.fastNlMeansDenoisingMulti(imgs, 6-1, 3);
            validateattributes(out, {class(imgs{1})}, {'size',size(imgs{1})});
        end

        function test_error_argnum
            try
                cv.fastNlMeansDenoisingMulti();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

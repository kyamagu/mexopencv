classdef TestFastNlMeansDenoisingColoredMulti
    %TestFastNlMeansDenoisingColoredMulti

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            imgs = repmat({img},1,5);
            out = cv.fastNlMeansDenoisingColoredMulti(imgs, 2, 3, 'H',10, 'HColor',10);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            % we use IMNOISE from Image Processing Toolbox
            if ~mexopencv.require('images')
                disp('SKIP');
                return;
            end

            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            imgs = cell(1,5);
            for i=1:numel(imgs)
                imgs{i} = imnoise(img, 'gaussian');
            end
            out = cv.fastNlMeansDenoisingColoredMulti(imgs, 2, 3, 'H',10, 'HColor',10);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.fastNlMeansDenoisingColoredMulti();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

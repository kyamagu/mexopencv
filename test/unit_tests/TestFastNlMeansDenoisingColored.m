classdef TestFastNlMeansDenoisingColored
    %TestFastNlMeansDenoisingColored

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            out = cv.fastNlMeansDenoisingColored(img, 'H',10, 'HColor',10);
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

            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            img = imnoise(img, 'gaussian');
            out = cv.fastNlMeansDenoisingColored(img, 'H',10, 'HColor',10);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.fastNlMeansDenoisingColored();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

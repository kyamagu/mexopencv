classdef TestFastNlMeansDenoisingColored
    %TestFastNlMeansDenoisingColored

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'Color',true, 'ReduceScale',2);
            out = cv.fastNlMeansDenoisingColored(img, 'H',10, 'HColor',10);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            % we use IMNOISE from Image Processing Toolbox
            if ~mexopencv.require('images')
                error('mexopencv:testskip', 'toolbox');
            end

            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'Color',true, 'ReduceScale',2);
            img = imnoise(img, 'gaussian');
            out = cv.fastNlMeansDenoisingColored(img, 'H',10, 'HColor',10);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.fastNlMeansDenoisingColored();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

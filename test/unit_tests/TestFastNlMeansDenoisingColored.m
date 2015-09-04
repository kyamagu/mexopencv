classdef TestFastNlMeansDenoisingColored
    %TestFastNlMeansDenoisingColored
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
    end

    methods (Static)
        function test_1
            img = imnoise(TestFastNlMeansDenoisingColored.im, 'gaussian');
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

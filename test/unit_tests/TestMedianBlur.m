classdef TestMedianBlur
    %TestMedianBlur

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','blox.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestMedianBlur.im);
            result = cv.medianBlur(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestMedianBlur.im);
            result = cv.medianBlur(img, 'KSize',7);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_3
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            result = cv.medianBlur(img, 'KSize',11);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.medianBlur();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

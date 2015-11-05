classdef TestCanny
    %TestCanny
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestCanny.im);
            [h,w,~] = size(img);
            result = cv.Canny(img, 192);
            validateattributes(result, {class(img)}, {'2d', 'size',[h,w]});
        end

        function test_2
            img = cv.imread(TestCanny.im, 'Grayscale',true);
            result = cv.Canny(img, 192);
            result = cv.Canny(img, [96,192]);
        end

        function test_3
            img = cv.imread(TestCanny.im, 'Grayscale',true);
            result = cv.Canny(img, 192, 'ApertureSize',5, 'L2Gradient',true);
        end

        function test_error_1
            try
                cv.Canny();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

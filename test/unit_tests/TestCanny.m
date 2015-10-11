classdef TestCanny
    %TestCanny
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_1
            result = cv.Canny(TestCanny.img, 192);
            [h,w,~] = size(TestCanny.img);
            validateattributes(result, {class(TestCanny.img)}, ...
                {'2d', 'size',[h,w]});
        end

        function test_2
            result = cv.Canny(rgb2gray(TestCanny.img), 192);
            result = cv.Canny(rgb2gray(TestCanny.img), [96,192]);
        end

        function test_3
            result = cv.Canny(rgb2gray(TestCanny.img), 192, ...
                'ApertureSize',5, 'L2Gradient',true);
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

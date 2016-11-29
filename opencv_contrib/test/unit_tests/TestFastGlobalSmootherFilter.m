classdef TestFastGlobalSmootherFilter
    %TestFastGlobalSmootherFilter

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestFastGlobalSmootherFilter.im);
            filt = cv.FastGlobalSmootherFilter(img, ...
                'Lambda',100, 'SigmaColor',5);
            dst = filt.filter(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestFastGlobalSmootherFilter.im);
            dst = cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter(...
                img, img, 'Lambda',100, 'SigmaColor',5);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end
    end

end

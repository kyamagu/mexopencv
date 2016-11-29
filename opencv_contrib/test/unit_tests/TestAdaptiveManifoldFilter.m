classdef TestAdaptiveManifoldFilter
    %TestAdaptiveManifoldFilter

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestAdaptiveManifoldFilter.im);
            filt = cv.AdaptiveManifoldFilter();
            filt.SigmaS = 16.0;
            dst = filt.filter(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestAdaptiveManifoldFilter.im);
            dst = cv.AdaptiveManifoldFilter.amFilter(img, img, ...
                'SigmaS',5.0, 'SigmaR',0.1);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end
    end

end

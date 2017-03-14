classdef TestDrawKeylines
    %TestDrawKeylines

    properties (Constant)
        img = fullfile(mexopencv.root(),'test','building.jpg');
    end

    methods (Static)
        function test_1
            im = cv.imread(TestDrawKeylines.img, 'Color',true, 'ReduceScale',2);
            detector = cv.LSDDetector();
            klines = detector.detect(im, 'Scale',2, 'NumOctaves',1);
            out = cv.drawKeylines(im, klines);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_2
            im = cv.imread(TestDrawKeylines.img, 'Color',true, 'ReduceScale',2);
            detector = cv.LSDDetector();
            klines = detector.detect(im, 'Scale',2, 'NumOctaves',1);
            out = cv.drawKeylines(im, klines, ...
                'OutImage',im, 'Color',[255 0 0]);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_error_argnum
            try
                cv.drawKeylines();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

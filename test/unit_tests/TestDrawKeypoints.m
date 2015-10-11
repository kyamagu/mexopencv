classdef TestDrawKeypoints
    %TestDrawKeypoints
    properties (Constant)
        img = fullfile(mexopencv.root(),'test','fruits.jpg');
    end

    methods (Static)
        function test_1
            im = imread(TestDrawKeypoints.img);
            detector = cv.FeatureDetector('ORB');
            kpts = detector.detect(im);
            out = cv.drawKeypoints(im, kpts);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_2
            im = imread(TestDrawKeypoints.img);
            detector = cv.FeatureDetector('ORB');
            kpts = detector.detect(im);
            out = cv.drawKeypoints(im, kpts, ...
                'OutImage',im, 'Color',[255 0 0], 'DrawRichKeypoints',true);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_error_1
            try
                cv.drawKeypoints();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

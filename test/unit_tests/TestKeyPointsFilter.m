classdef TestKeyPointsFilter
    %TestKeyPointsFilter

    properties (Constant)
    end

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            [h,w,~] = size(img);

            detector = cv.FeatureDetector('ORB');
            kp = detector.detect(img);

            kp2 = cv.KeyPointsFilter.runByImageBorder(kp, [w,h], 50);
            assert(isstruct(kp2));

            kp2 = cv.KeyPointsFilter.runByKeypointSize(kp, 30, 90);
            assert(isstruct(kp2));

            kp2 = cv.KeyPointsFilter.runByPixelsMask(kp, rand(h,w)>0.5);
            assert(isstruct(kp2));

            kp2 = cv.KeyPointsFilter.removeDuplicated(kp);
            assert(isstruct(kp2));

            kp2 = cv.KeyPointsFilter.retainBest(kp, 50);
            assert(isstruct(kp2));
        end
    end

end

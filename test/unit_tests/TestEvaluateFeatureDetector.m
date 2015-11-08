classdef TestEvaluateFeatureDetector
    %TestEvaluateFeatureDetector
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','fruits.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestEvaluateFeatureDetector.im);
            H = eye(3);
            detector = cv.FeatureDetector('AgastFeatureDetector');
            kp = detector.detect(img);
            [repeat, correspCount] = cv.evaluateFeatureDetector(img, img, H, kp, kp);
            validateattributes(repeat, {'numeric'}, {'scalar'});
            validateattributes(correspCount, {'numeric'}, {'scalar', 'integer'});
            %assert(repeat == 1.0);
            %assert(correspCount == numel(kp));
        end

        function test_2
            H = [0.8 -0.04 50; -0.05 0.9 50; 1e-5 1e-4 1];
            img1 = imread(TestEvaluateFeatureDetector.im);
            img2 = cv.warpPerspective(img1, H);
            [repeat, correspCount] = cv.evaluateFeatureDetector(...
                img1, img2, H, {}, {}, 'Detector',{'ORB', 'MaxFeatures',500});
            validateattributes(repeat, {'numeric'}, {'scalar'});
            validateattributes(correspCount, {'numeric'}, {'scalar', 'integer'});
        end

        function test_error_1
            try
                cv.evaluateFeatureDetector();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestEvaluateFeatureDetector
    %TestEvaluateFeatureDetector

    properties (Constant)
    end

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            H = eye(3);
            detector = cv.FeatureDetector('AgastFeatureDetector');
            kp = detector.detect(img);
            [repeat, correspCount] = cv.evaluateFeatureDetector(img, img, H, kp, kp);
            %assert(repeat == 1.0);
            %assert(correspCount == numel(kp));
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

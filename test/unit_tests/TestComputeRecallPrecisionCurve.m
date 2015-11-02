classdef TestComputeRecallPrecisionCurve
    %TestComputeRecallPrecisionCurve

    methods (Static)
        function test_1
            H = [0.8 -0.04 50; -0.05 0.9 50; 1e-5 1e-4 1];
            img1 = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            img2 = cv.warpPerspective(img1, H);

            obj = cv.ORB();
            [~, feat1] = obj.detectAndCompute(img1);
            [~, feat2] = obj.detectAndCompute(img2);
            matcher = cv.DescriptorMatcher('BruteForce-Hamming');
            matches1to2 = matcher.radiusMatch(feat1, feat2, 100);

            %TODO: fake correct matches (see cv::evaluateGenericDescriptorMatcher)
            % Ideally we would look into the thresold overlap mask matrix
            correctMatches1to2Mask = cell(size(matches1to2));
            for i=1:numel(matches1to2)
                [~,ord] = sort([matches1to2{i}.distance]);
                mask = false(size(ord));
                mask(ord(1:fix(end/2))) = true;
                correctMatches1to2Mask{i} = mask;
            end

            recallPrecisionCurve = cv.computeRecallPrecisionCurve(...
                matches1to2, correctMatches1to2Mask);
            validateattributes(recallPrecisionCurve, {'numeric'}, ...
                {'2d', 'size',[NaN 2]});
            %plot(recallPrecisionCurve(:,1), recallPrecisionCurve(:,2))
        end

        function test_error_1
            try
                cv.computeRecallPrecisionCurve();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

%{
function nearestPointIndex = getNearestPoint(recallPrecisionCurve, l_precision)
    if (0 <= l_precision && l_precision <= 1)
        [~,nearestPointIndex] = min(abs(recallPrecisionCurve(:,1) - l_precision));
    else
        nearestPointIndex = -1;
end

function recall = getRecall(recallPrecisionCurve, l_precision)
    nearestPointIndex = getNearestPoint(recallPrecisionCurve, l_precision);
    if nearestPointIndex > 0
        recall = recallPrecisionCurve(nearestPointIndex,2);
    else
        recall = -1.0;
    end
end
%}

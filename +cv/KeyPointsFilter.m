classdef KeyPointsFilter
    %KEYPOINTSFILTER  Methods to filter a vector of keypoints.
    %
    % See also: cv.FeatureDetector
    %

    methods (Static)
        function keypoints = runByImageBorder(keypoints, imgSize, borderSize)
            %RUNBYIMAGEBORDER  Remove keypoints within borderPixels of an image edge.
            %
            %    keypoints = cv.KeyPointsFilter.runByImageBorder(keypoints, imgSize, borderSize)
            %
            % ## Input
            % * __keypoints__ input collection of keypoints.
            % * __imgSize__ image size `[width,height]`
            % * __borderSize__ border size
            %
            % ## Output
            % * __keypoints__ output filtered keypoints.
            %
            keypoints = KeyPointsFilter_('runByImageBorder', keypoints, imgSize, borderSize);
        end

        function keypoints = runByKeypointSize(keypoints, minSize, maxSize)
            %RUNBYKEYPOINTSIZE  Remove keypoints of sizes out of range.
            %
            %    keypoints = cv.KeyPointsFilter.runByKeypointSize(keypoints, minSize, maxSize)
            %
            % ## Input
            % * __keypoints__ input collection of keypoints.
            % * __minSize__ minimum keypoint size
            % * __maxSize__ maximum keypoint size. default `realmax('single')`
            %
            % ## Output
            % * __keypoints__ output filtered keypoints.
            %
            keypoints = KeyPointsFilter_('runByKeypointSize', keypoints, minSize, maxSize);
        end

        function keypoints = runByPixelsMask(keypoints, mask)
            %RUNBYPIXELSMASK  Remove keypoints from some image by mask for pixels of this image.
            %
            %    keypoints = cv.KeyPointsFilter.runByPixelsMask(keypoints, mask)
            %
            % ## Input
            % * __keypoints__ input collection of keypoints.
            % * __mask__ image mask
            %
            % ## Output
            % * __keypoints__ output filtered keypoints.
            %
            keypoints = KeyPointsFilter_('runByPixelsMask', keypoints, mask);
        end

        function keypoints = removeDuplicated(keypoints)
            %REMOVEDUPLICATED  Remove duplicated keypoints.
            %
            %    keypoints = cv.KeyPointsFilter.removeDuplicated(keypoints)
            %
            % ## Input
            % * __keypoints__ input collection of keypoints.
            %
            % ## Output
            % * __keypoints__ output filtered keypoints.
            %
            keypoints = KeyPointsFilter_('removeDuplicated', keypoints);
        end

        function keypoints = retainBest(keypoints, npoints)
            %RETAINBEST  Retain the specified number of the best keypoints (according to the response).
            %
            %    keypoints = cv.KeyPointsFilter.retainBest(keypoints, npoints)
            %
            % ## Input
            % * __keypoints__ input collection of keypoints.
            % * __npoints__ number of keypoints to retain
            %
            % ## Output
            % * __keypoints__ output filtered keypoints.
            %
            keypoints = KeyPointsFilter_('retainBest', keypoints, npoints);
        end
    end

end

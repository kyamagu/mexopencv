classdef KeyPointsFilter
    %KEYPOINTSFILTER  Methods to filter a vector of keypoints.
    %
    % A keypoint is a data structure for salient point detectors.
    %
    % The struct stores a keypoint, i.e. a point feature found by one of many
    % available keypoint detectors, such as Harris corner detector, cv.FAST,
    % cv.StarDetector, cv.SURF, cv.SIFT, cv.FeatureDetector etc.
    %
    % The keypoint is characterized by the 2D position, scale (proportional to
    % the diameter of the neighborhood that needs to be taken into account),
    % orientation and some other parameters. The keypoint neighborhood is then
    % analyzed by another algorithm that builds a descriptor (usually
    % represented as a feature vector). The keypoints representing the same
    % object in different images can then be matched using
    % cv.DescriptorMatcher or another method.
    %
    % The keypoint struct contains the following fields:
    % * __pt__ coordinates of the keypoint `[x,y]`.
    % * __size__ diameter of the meaningful keypoint neighborhood.
    % * __angle__ computed orientation of the keypoint (-1 if not applicable);
    %       it's in [0,360) degrees and measured relative to image coordinate
    %       system, ie in clockwise.
    % * __response__ the response by which the most strong keypoints have been
    %       selected. Can be used for the further sorting or subsampling.
    % * __octave__ octave (pyramid layer) from which the keypoint has been
    %       extracted.
    % * **class_id** object class (if the keypoints need to be clustered by an
    %       object they belong to).
    %
    % See also: cv.FeatureDetector
    %

    %% KeyPointsFilter
    methods (Static)
        function keypoints = runByImageBorder(keypoints, imgSize, borderSize)
            %RUNBYIMAGEBORDER  Remove keypoints within borderPixels of an image edge.
            %
            %    keypoints = cv.KeyPointsFilter.runByImageBorder(keypoints, imgSize, borderSize)
            %
            % ## Input
            % * __keypoints__ input collection of keypoints.
            % * __imgSize__ image size `[width,height]`.
            % * __borderSize__ border size, should be a positive number.
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
            % * __minSize__ minimum keypoint size.
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
            % * __mask__ image mask.
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
            % * __npoints__ number of keypoints to retain.
            %
            % ## Output
            % * __keypoints__ output filtered keypoints.
            %
            % This method takes keypoints and culls them by the response.
            %
            keypoints = KeyPointsFilter_('retainBest', keypoints, npoints);
        end
    end

    %% KeyPoint
    methods (Static)
        function points2f = convertToPoints(keypoints, varargin)
            %CONVERTTOPOINTS  Convert vector of keypoints to vector of points
            %
            %    points2f = cv.KeyPointsFilter.convertToPoints(keypoints)
            %    points2f = cv.KeyPointsFilter.convertToPoints(keypoints, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __keypoints__ Keypoints obtained from any feature detection
            %       algorithm like SIFT/SURF/ORB.
            %
            % ## Output
            % * __points2f__ Array of (x,y) coordinates of each keypoint.
            %
            % ## Options
            % * __Indices__ Optional array of indexes of keypoints to be
            %       converted to points. (Acts like a mask to convert only
            %       specified keypoints). Not set by default.
            %
            % See also: cv.KeyPointsFilter.convertFromPoints
            %
            points2f = KeyPointsFilter_('convertToPoints', keypoints, varargin{:});
        end

        function keypoints = convertFromPoints(points2f, varargin)
            %CONVERTFROMPOINTS  Convert vector of points to vector of keypoints, where each keypoint is assigned the same size and the same orientation
            %
            %    keypoints = cv.KeyPointsFilter.convertFromPoints(points2f)
            %    keypoints = cv.KeyPointsFilter.convertFromPoints(points2f, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __points2f__ Array of (x,y) coordinates of each keypoint.
            %
            % ## Output
            % * __keypoints__ Keypoints similar to those obtained from any
            %       feature detection algorithm like SIFT/SURF/ORB.
            %
            % ## Options
            % * __Size__ keypoint diameter.
            % * __Response__ keypoint detector response on the keypoint (that
            %       is, strength of the keypoint).
            % * __Octave__ pyramid octave in which the keypoint has been
            %       detected.
            % * __ClassId__ object id.
            %
            % See also: cv.KeyPointsFilter.convertToPoints
            %
            keypoints = KeyPointsFilter_('convertFromPoints', points2f, varargin{:});
        end

        function ovrl = overlap(kp1, kp2)
            %OVERLAP  Compute overlap for pair of keypoints
            %
            %    ovrl = cv.KeyPointsFilter.overlap(kp1, kp2)
            %
            % ## Input
            % * __kp1__ First keypoint.
            % * __kp2__ Second keypoint.
            %
            % ## Output
            % * __ovrl__ Overlap is the ratio between area of keypoint
            %       regions' intersection and area of keypoint regions' union
            %       (considering keypoint region as circle). If they don't
            %       overlap, we get zero. If they coincide at same location
            %       with same size, we get 1.
            %
            ovrl = KeyPointsFilter_('overlap', kp1, kp2);
        end

        function val = hash(kp)
            %HASH  Compute hash of a keypoint
            %
            %    val = cv.KeyPointsFilter.hash(kp)
            %
            % ## Input
            % * __kp__ input keypoint.
            %
            % ## Output
            % * __val__ integer hash value
            %
            val = KeyPointsFilter_('hash', kp);
        end
    end

end

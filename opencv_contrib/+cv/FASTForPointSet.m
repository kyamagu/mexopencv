%FASTFORPOINTSET  Estimates cornerness for pre-specified KeyPoints using the FAST algorithm
%
%     keypoints = cv.FASTForPointSet(im, keypoints)
%     keypoints = cv.FASTForPointSet(im, keypoints, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ 8-bit grayscale image where keypoints (corners) are to be detected.
% * __keypoints__ keypoints which should be tested to fit the FAST criteria.
%   A 1-by-N structure array, with at least the "pt" field filled. In the
%   output, keypoints not being detected as corners are removed.
%
% ## Output
% * __keypoints__ Keypoints detected on the image. With their "response" field
%   calculated.
%
% ## Options
% * __Threshold__ Threshold on difference between intensity of the central
%   pixel and pixels on a circle around this pixel. default 10.
% * __NonmaxSuppression__ If it is true, non-maximum supression is applied to
%   detected corners (keypoints). default true.
% * __Type__ one of the three neighborhoods as defined in the paper:
%   * **TYPE_9_16** (default)
%   * **TYPE_7_12**
%   * **TYPE_5_8**
%
% Detects corners using the FAST algorithm by [Rosten06].
%
% Rational: Some applications only want to know if there are feature at
% specific locations. To fit these needs the cv.FAST approach is extended in
% cv.FASTForPointSet to recieve a vector of locations and calculates the FAST
% response on these positions. If it is below the threshold, it will be
% removed from the list.
%
% ## References
% [Rosten06]:
% > E. Rosten (Machine Learning for High-speed Corner Detection, 2006).
%
% See also: cv.FAST, cv.FastFeatureDetector
%

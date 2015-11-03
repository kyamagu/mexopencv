%FAST  Detects corners using the FAST algorithm
%
%    keypoints = cv.FAST(im)
%    keypoints = cv.FAST(im, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ 8-bit grayscale image where keypoints (corners) are to be detected.
%
% ## Output
% * __keypoints__ Keypoints detected on the image. A 1-by-N structure array.
%       It has the following fields:
%       * __pt__ coordinates of the keypoint [x,y]
%       * __size__ diameter of the meaningful keypoint neighborhood
%       * __angle__ computed orientation of the keypoint (-1 if not applicable).
%             Its possible values are in a range [0,360) degrees. It is measured
%             relative to image coordinate system (y-axis is directed downward),
%             ie in clockwise.
%       * __response__ the response by which the most strong keypoints have been
%             selected. Can be used for further sorting or subsampling.
%       * __octave__ octave (pyramid layer) from which the keypoint has been
%             extracted.
%       * **class_id** object id that can be used to clustered keypoints by an
%             object they belong to.
%
% ## Options
% * __Threshold__ Threshold on difference between intensity of the central
%        pixel and pixels on a circle around this pixel. See the algorithm
%        description [Rosten06]. default 10.
% * __NonmaxSuppression__ If it is true, non-maximum supression is applied
%        to detected corners (keypoints). default true.
% * __Type__ one of the three neighborhoods as defined in the paper:
%       * **TYPE_9_16** (default)
%       * **TYPE_7_12**
%       * **TYPE_5_8**
%
% Detects corners using the FAST algorithm by [Rosten06].
%
% ## References
% [Rosten06]:
% > E. Rosten (Machine Learning for High-speed Corner Detection, 2006).
%
% See also: cv.FastFeatureDetector, cv.AGAST, cv.FeatureDetector,
%  detectFASTFeatures
%

%MATCHGMS  GMS (Grid-based Motion Statistics) feature matching strategy
%
%     matchesGMS = cv.matchGMS(size1, keypoints1, size2, keypoints2, matches1to2)
%     matchesGMS = cv.matchGMS(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __size1__ Size of first image `[w,h]`.
% * __keypoints1__ Keypoints from the first source image. A 1-by-N structure
%   array with the following fields:
%   * __pt__ coordinates of the keypoint `[x,y]`
%   * __size__ diameter of the meaningful keypoint neighborhood
%   * __angle__ computed orientation of the keypoint (-1 if not applicable).
%     Its possible values are in a range [0,360) degrees. It is measured
%     relative to image coordinate system (y-axis is directed downward), i.e
%     in clockwise.
%   * __response__ the response by which the most strong keypoints have been
%     selected. Can be used for further sorting or subsampling.
%   * __octave__ octave (pyramid layer) from which the keypoint has been
%     extracted.
%   * **class_id** object id that can be used to clustered keypoints by an
%     object they belong to.
% * __size2__ Size of second image `[w,h]`.
% * __keypoints2__ Keypoints from the second source image. Same format as
%   `keypoints1`.
% * __matches1to2__ Input 1-nearest neighbor matches from the first image to
%   the second one. A 1-by-M structure array with the following fields:
%   * __queryIdx__ query descriptor index (zero-based index)
%   * __trainIdx__ train descriptor index (zero-based index)
%   * __imgIdx__ train image index (zero-based index)
%   * __distance__ distance between descriptors (scalar)
%
% ## Output
% * __matchesGMS__ Matches returned by the GMS matching strategy.
%
% ## Options
% * __WithRotation__ Take rotation transformation into account. default false
% * __WithScale__ Take scale transformation into account. default false
% * __ThresholdFactor__ The higher, the less matches. default 6.0
%
% GMS feature matching strategy by [Bian2017gms].
%
% ## Notes
% * Since GMS works well when the number of features is large, we recommend to
%   use cv.ORB features and set `FastThreshold` to 0 to get as many features
%   as possible quickly.
% * If matching results are not satisfying, please add more features (we use
%   10000 for images with 640x480 size).
% * If your images have big rotation and scale changes, please set
%   `WithRotation` or `WithScale` to true.
%
% ## References
% [Bian2017gms]:
% > JiaWang Bian, Wen-Yan Lin, Yasuyuki Matsushita, Sai-Kit Yeung, Tan Dat
% > Nguyen, and Ming-Ming Cheng. "GMS: Grid-based motion statistics for fast,
% > ultra-robust feature correspondence".
% > In IEEE Conference on Computer Vision and Pattern Recognition, 2017.
%
% See also: cv.FeatureDetector, cv.DescriptorMatcher, cv.drawMatches
%

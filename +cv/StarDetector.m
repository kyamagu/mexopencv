%STARDETECTOR  Finds keypoints in an image
%
%    keypoints = cv.StarDetector(im)
%    keypoints = cv.StarDetector(im, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ The input 8-bit grayscale image
%
% ## Output
% * __keypoints__ The output vector of keypoints.
%
% ## Options
% * __MaxSize__ maximum size of the features. The following values are
%       supported: 4, 6, 8, 11, 12, 16, 22, 23, 32, 45, 46, 64, 90, 128.
%       In the case of a different value the result is undefined.
% * __ResponseThreshold__ threshold for the approximated laplacian, used to
%       eliminate weak features. The larger it is, the less features will
%       be retrieved.
% * __LineThresholdProjected__ another threshold for the laplacian to
%       eliminate edges
% * __LineThresholdBinarized__ yet another threshold for the feature size
%       to eliminate edges. The larger the 2nd threshold, the more points
%       you get.
%
% See also cv.FeatureDetector
%

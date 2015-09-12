%EVALUATEFEATUREDETECTOR  Evaluates a feature detector
%
%    [repeatability, correspCount] = cv.evaluateFeatureDetector(img1, img2, H1to2, keypoints1, keypoints2)
%    [...] = cv.evaluateFeatureDetector(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img1__ First image.
% * __img2__ Second image.
% * __H1to2__ 3x3 double matrix. Homography relating `img1` to `img2`.
% * __keypoints1__ Keypoints detected in `img1`
% * __keypoints2__ Keypoints detected in `img2`
%
% ## Output
% * __repeatability__ Repeatability (float value), between 0.0 and 1.0
% * __correspCount__ Correspondences count (int value).
%
% ## Options
% * __Detector__ feature detector that finds keypoints in images. It can be
%       specified as a string containing the type of feature detector, such as
%       'ORB'. It can also be specified as a cell-array of the form
%       `{fdetector, 'key',val, ...}`, where the first element is the type,
%       and the remaining elements are optional parameters used to construct
%       the specified feature detector. See cv.FeatureDetector for possible
%       types. Not set by default (i.e: you must supply pre-detected keypoints
%       in the inputs).
%
% ## Example:
%
%    detector = cv.FeatureDetector('SURF');
%    kp1 = detector.detect(img1)
%    kp2 = detector.detect(img2)
%    [rep,corresp] = cv.evaluateFeatureDetector(img1, img2, H1to2, kp1, kp2)
%
% See also: cv.computeRecallPrecisionCurve, cv.FeatureDetector
%

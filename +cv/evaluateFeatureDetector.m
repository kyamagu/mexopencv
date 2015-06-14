%EVALUATEFEATUREDETECTOR  Evalutes a feature detector
%
%    [repeatability, correspCount] = cv.evaluateFeatureDetector(img1, img2, H1to2, keypoints1, keypoints2)
%
% ## Input
% * __img1__
% * __img2__
% * __H1to2__ Homography, 3x3 double matrix
% * __keypoints1__ Keypoints detected in `img1`
% * __keypoints2__ Keypoints detected in `img2`
%
% ## Output
% * __repeatability__ float value
% * __correspCount__ int value
%
% ## Example:
%
%    detector = cv.FeatureDetector('SURF');
%    kp1 = detector.detect(img1)
%    kp2 = detector.detect(img2)
%    [rep,corresp] = cv.evaluateFeatureDetector(img1, img2, H1to2, kp1, kp2)
%
% See also: cv.FeatureDetector
%

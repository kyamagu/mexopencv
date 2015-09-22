%FINDESSENTIALMAT  Calculates an essential matrix from the corresponding points in two images
%
%    E = cv.findEssentialMat(points1, points2)
%    [E, mask] = cv.findEssentialMat(...)
%    [...] = cv.findEssentialMat(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __points1__ Cell array of N (N>=5) 2D points from the first image, or numeric array
%       Nx2/Nx1x2/1xNx2. The point coordinates should be floating-point
%       (single or double precision).
% * __points2__ Cell array or numeric array of the second image points of the
%       same size and format as `points1`.
%
% ## Output
% * __E__ Essential matrix, 3x3.
% * __mask__ Output vector of N elements, every element of which is set to 0
%       for outliers and to 1 for the other points (inliers). The array is
%       computed only in the RANSAC and LMedS robust methods.
%
% ## Options
% * __Focal__ focal length of the camera. Note that this function assumes that
%       `points1` and `points2` are feature points from cameras with same
%       focal length and principle point. default 1.0
% * __PrincipalPoint__ principle point of the camera `[ppx,ppy]`.
%       default [0,0]
% * __Method__ Method for computing a essential matrix. One of:
%       * __Ransac__ for the RANSAC algorithm. (default)
%       * __LMedS__ for the LMedS algorithm.
% * __Threshold__ Parameter used for RANSAC. It is the maximum distance from a
%       point to an epipolar line in pixels, beyond which the point is
%       considered an outlier and is not used for computing the final
%       essential matrix. It can be set to something like 1-3, depending
%       on the accuracy of the point localization, image resolution, and
%       the image noise. default 1.0
% * __Confidence__ Parameter used for the RANSAC or LMedS methods only. It
%       specifies a desirable level of confidence (probability) that the
%       estimated matrix is correct. In the range 0..1 exclusive.
%       default 0.999
%
% This function estimates essential matrix based on the five-point algorithm
% solver in [Nister03]. [SteweniusCFS] is also a related. The epipolar
% geometry is described by the following equation:
%
%    [p2;1]' * inv(K)' * E * inv(K) * [p1;1] = 0
%
%    K = [f 0 xpp;
%         0 f ypp;
%         0 0   1]
%
% where `E` is an essential matrix, `p1` and `p2` are corresponding points in
% the first and the second images, respectively. The result of this function
% may be passed further to cv.decomposeEssentialMat or cv.recoverPose to
% recover the relative pose between cameras.
%
% ## Example
% Estimation of essential matrix using the RANSAC algorithm:
%
%    % initialize the points here
%    points1 = {[1,1],[3,1],[5,1],...}
%    points2 = {[2,3],[4,3],[6,3],...}
%    % estimate essential matrix
%    [E, mask] = cv.findEssentialMat(points1, points2, 'Method','Ransac');
%
% ## References
% [Nister03]:
% > David Nister. "An efficient solution to the five-point relative pose
% > problem". Pattern Analysis and Machine Intelligence, IEEE Transactions on,
% > 26(6):756-770, 2004.
%
% [SteweniusCFS]:
% > Henrik Stewenius. "Calibrated fivepoint solver".
%
% See also: cv.findFundamentalMat, cv.recoverPose
%

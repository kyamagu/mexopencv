%FINDFUNDAMENTALMAT  Calculates a fundamental matrix from the corresponding points in two images
%
%    F = cv.findFundamentalMat(points1, points2)
%    [F, mask] = cv.findFundamentalMat(...)
%    [...] = cv.findFundamentalMat(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __points1__ Cell array of N points from the first image, or numeric array
%       Nx2/Nx1x2/1xNx2. The point coordinates should be floating-point
%       (single or double precision).
% * __points2__ Cell array or numeric array of the second image points of the
%       same size and format as `points1`.
%
% ## Output
% * __F__ Fundamental matrix, 3x3 (or 9x3 in some cases, see below).
% * __mask__ Optional output mask set by a robust method (RANSAC or LMEDS),
%       indicates inliers. Vector of same length as number of points.
%
% ## Options
% * __Method__ Method for computing a fundamental matrix. One of:
%       * __7Point__ for a 7-point algorithm. `N = 7`.
%       * __8Point__ for an 8-point algorithm. `N >= 8`.
%       * __Ransac__ for the RANSAC algorithm. `N >= 8`. (default)
%       * __LMedS__ for the LMedS algorithm. `N >= 8`.
% * __Param1__ Parameter used for RANSAC. It is the maximum distance from a
%       point to an epipolar line in pixels, beyond which the point is
%       considered an outlier and is not used for computing the final
%       fundamental matrix. It can be set to something like 1-3, depending
%       on the accuracy of the point localization, image resolution, and
%       the image noise. default 3.0
% * __Param2__ Parameter used for the RANSAC or LMedS methods only. It
%       specifies a desirable level of confidence (probability) that the
%       estimated matrix is correct. In the range 0..1 exclusive. default 0.99
%
% The epipolar geometry is described by the following equation:
%
%    [p2;1]^T * F * [p1;1] = 0
%
% where `F` is a fundamental matrix, `p1` and `p2` are corresponding points in
% the first and the second images, respectively.
%
% The function calculates the fundamental matrix using one of four methods
% listed above and returns the found fundamental matrix. Normally just one
% matrix is found. But in case of the 7-point algorithm, the function may
% return up to 3 solutions (9x3 matrix that stores all 3 matrices
% sequentially).
%
% The calculated fundamental matrix may be passed further to
% cv.computeCorrespondEpilines that finds the epipolar lines corresponding
% to the specified points. It can also be passed to
% cv.stereoRectifyUncalibrated to compute the rectification transformation.
%
% ## Example
% Estimation of fundamental matrix using the RANSAC algorithm:
%
%    % initialize the points here
%    points1 = {[1,1],[3,1],[5,1],...}
%    points2 = {[2,3],[4,3],[6,3],...}
%    % estimate fundamental matrix
%    [F, mask] = cv.findFundamentalMat(points1, points2, 'Method','Ransac');
%
% See also: cv.computeCorrespondEpilines, cv.stereoRectifyUncalibrated,
%  estimateFundamentalMatrix
%

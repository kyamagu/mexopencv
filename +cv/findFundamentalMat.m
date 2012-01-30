%FINDFUNDAMENTALMAT  Calculates a fundamental matrix from the corresponding points in two images
%
%   F = cv.findFundamentalMat(points1, points2)
%   [F, mask] = cv.findFundamentalMat(...)
%   [...] = cv.findFundamentalMat(..., 'OptionName', optionValue, ...)
%
% Input:
%    points1: Cell array of N points from the first image.
%    points2: Cell array of the second image points of the same size as
%        points1.
% Output:
%    F: Fundamental matrix.
%    mask: Mask array.
% Options:
%    'Method': Method for computing a fundamental matrix. One of the
%        following:
%        '7Point': 7-point algorithm. N = 7.
%        '8Point': 8-point algorithm. N >= 8.
%        'Ransac': RANSAC algorithm. N >= 8. (default)
%        'LMedS': LMedS algorithm. N >= 8.
%    'Param1': Parameter used for RANSAC. It is the maximum distance from a
%        point to an epipolar line in pixels, beyond which the point is
%        considered an outlier and is not used for computing the final
%        fundamental matrix. It can be set to something like 1-3, depending
%        on the accuracy of the point localization, image resolution, and
%        the image noise. default 3.0.
%    'Param2': Parameter used for the RANSAC or LMedS methods only. It
%        specifies a desirable level of confidence (probability) that the
%        estimated matrix is correct. default 0.99.
%
% The epipolar geometry is described by the following equation:
%
%    [p2;1]^T * F * [p1;1] = 0
%
% where F is a fundamental matrix, p1 and p2 are corresponding points in
% the first and the second images, respectively.
%
% The function calculates the fundamental matrix using one of four methods
% listed above and returns the found fundamental matrix. Normally just one
% matrix is found. But in case of the 7-point algorithm, the function may
% return up to 3 solutions (9 x 3 matrix that stores all 3 matrices
% sequentially).
%
% The calculated fundamental matrix may be passed further to
% cv.computeCorrespondEpilines that finds the epipolar lines corresponding
% to the specified points. It can also be passed to
% cv.stereoRectifyUncalibrated to compute the rectification transformation.
%
% See also cv.computeCorrespondEpilines cv.stereoRectifyUncalibrated
%
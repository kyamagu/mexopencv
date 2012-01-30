%ESTIMATEAFFINE3D  Computes an optimal affine transformation between two 3D point sets
%
%   M = cv.estimateAffine3D(srcpt, points2)
%   [M, inliers] = cv.estimateAffine3D(...)
%   [...] = cv.estimateAffine3D(..., 'OptionName', optionValue, ...)
%
% Input:
%    srcpt: First input 3D point set. Cell array of 3-element vectors or
%        1-by-N-by-3 numeric array.
%    dstpt: Second input 3D point set. Cell array of 3-element vectors or
%        1-by-N-by-3 numeric array.
% Output:
%    M: 3D affine transformation matrix
%    inliers: Output vector indicating which points are inliers.
% Options:
%    'RansacThreshold': Maximum reprojection error in the RANSAC algorithm
%        to consider a point as an inlier. default 3.0.
%    'Param2': Confidence level, between 0 and 1, for the estimated
%        transformation. Anything between 0.95 and 0.99 is usually good
%        enough. Values too close to 1 can slow down the estimation
%        significantly. Values lower than 0.8-0.9 can result in an
%        incorrectly estimated transformation. default 0.99.
%
% The function estimates an optimal 3D affine transformation between two 3D
% point sets using the RANSAC algorithm.
%
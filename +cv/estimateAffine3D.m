%ESTIMATEAFFINE3D  Computes an optimal affine transformation between two 3D point sets
%
%    M = cv.estimateAffine3D(src, dst)
%    [M, inliers] = cv.estimateAffine3D(...)
%    [...] = cv.estimateAffine3D(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ First input 3D point set. Cell array of 3-element vectors
%       `{[x,y,z],...}` or Nx3/Nx1x3/1xNx3 numeric array.
% * __dst__ Second input 3D point set. Same size and type as `src`.
%
% ## Output
% * __M__ Output 3D affine transformation matrix 3x4
% * __inliers__ Output vector of same length as number of points, indicating
%       which points are inliers.
% * __result__ success flag.
%
% ## Options
% * __RansacThreshold__ Maximum reprojection error in the RANSAC algorithm
%       to consider a point as an inlier. default 3.0.
% * __Confidence__ Confidence level, between 0 and 1, for the estimated
%       transformation. Anything between 0.95 and 0.99 is usually good
%       enough. Values too close to 1 can slow down the estimation
%       significantly. Values lower than 0.8-0.9 can result in an
%       incorrectly estimated transformation. default 0.99.
%
% The function estimates an optimal 3D affine transformation between two 3D
% point sets using the RANSAC algorithm.
%

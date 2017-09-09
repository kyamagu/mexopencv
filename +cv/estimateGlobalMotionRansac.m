%ESTIMATEGLOBALMOTIONRANSAC  Estimates best global motion between two 2D point clouds robustly (using RANSAC method)
%
%     M = cv.estimateGlobalMotionRansac(points0, points1)
%     [M,rmse,ninliers] = cv.estimateGlobalMotionRansac(points0, points1)
%     [...] = cv.estimateGlobalMotionRansac(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __points0__ Source set of 2D points of type `single`, stored in numeric
%   array (Nx2/Nx1x2/1xNx2) or cell-array of 2-element vectors
%   `{[x,y], [x,y], ...}`.
% * __points1__ Destination set of 2D points of type `single`, of same format
%   as `points0`.
%
% ## Output
% * __M__ 3x3 2D transformation matrix of type `single`.
% * __rmse__ Final root-mean-square error.
% * __ninliers__ Final number of inliers.
%
% ## Options
% * __MotionModel__ Motion model between two point clouds. One of:
%   * __Translation__
%   * __TranslationAndScale__
%   * __Rotation__
%   * __Rigid__
%   * __Similarity__
%   * __Affine__ (default)
% * __RansacParams__ RANSAC method parameters. A struct with the following
%   fields:
%   * __Size__ Subset size.
%   * __Thresh__ Maximum re-projection error value to classify as inlier.
%   * __Eps__ Maximum ratio of incorrect correspondences.
%   * __Prob__ Required success probability.
%
%   If a string is passed, it uses the default RANSAC parameters for the given
%   motion model. Here are the defaults corresponding to each motion model:
%
%   * __Translation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
%   * __TranslationAndScale__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
%   * __Rotation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
%   * __Rigid__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
%   * __Similarity__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
%   * __Affine__ `struct('Size',3, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
%
%   By default is it set to 'Affine'.
%
% See also: cv.estimateGlobalMotionLeastSquares
%

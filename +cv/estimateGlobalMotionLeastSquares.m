%ESTIMATEGLOBALMOTIONLEASTSQUARES  Estimates best global motion between two 2D point clouds in the least-squares sense
%
%     M = cv.estimateGlobalMotionLeastSquares(points0, points1)
%     [M,rmse] = cv.estimateGlobalMotionLeastSquares(points0, points1)
%     [...] = cv.estimateGlobalMotionLeastSquares(..., 'OptionName',optionValue, ...)
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
%
% ## Options
% * __MotionModel__ Motion model between two point clouds. One of:
%   * __Translation__
%   * __TranslationAndScale__
%   * __Rotation__
%   * __Rigid__
%   * __Similarity__
%   * __Affine__ (default)
%
% See also: cv.estimateGlobalMotionRansac
%

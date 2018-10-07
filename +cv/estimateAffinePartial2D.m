%ESTIMATEAFFINEPARTIAL2D  Computes an optimal limited affine transformation with 4 degrees of freedom between two 2D point sets
%
%     H = cv.estimateAffinePartial2D(from, to)
%     [H, inliers] = cv.estimateAffinePartial2D(...)
%     [...] = cv.estimateAffinePartial2D(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __from__ First input 2D point set. Cell array of 2-element vectors
%   `{[x,y],...}` or Nx2/Nx1x2/1xNx2 numeric array.
% * __to__ Second input 2D point set. Same size and type as `from`.
%
% ## Output
% * __H__ Output 2D affine transformation (4 degrees of freedom) matrix 2x3 or
%   empty matrix if transformation could not be estimated.
% * __inliers__ Output vector of same length as number of points, indicating
%   which points are inliers.
%
% ## Options
% * __Method__ Robust method used to compute transformation. RANSAC is the
%   default method. The following methods are possible:
%   * __Ransac__ RANSAC-based robust method.
%   * __LMedS__ Least-Median of squares robust method
% * __RansacThreshold__ Maximum reprojection error in the RANSAC algorithm to
%   consider a point as an inlier. Applies only to RANSAC. default 3.0.
% * __MaxIters__ The maximum number of robust method iterations. default 2000
% * __Confidence__ Confidence level, between 0 and 1, for the estimated
%   transformation. Anything between 0.95 and 0.99 is usually good enough.
%   Values too close to 1 can slow down the estimation significantly. Values
%   lower than 0.8-0.9 can result in an incorrectly estimated transformation.
%   default 0.99.
% * __RefineIters__ Maximum number of iterations of refining algorithm
%   (Levenberg-Marquardt). Passing 0 will disable refining, so the output
%   matrix will be output of robust method. default 10
%
% The function estimates an optimal 2D affine transformation with 4 degrees of
% freedom limited to combinations of translation, rotation, and uniform
% scaling. Uses the selected algorithm for robust estimation.
%
% The computed transformation is then refined further (using only inliers)
% with the Levenberg-Marquardt method to reduce the re-projection error even
% more.
%
% Estimated transformation matrix is:
%
%     [cos(theta)*s, -sin(theta)*s, tx;
%      sin(theta)*s,  cos(theta)*s, ty]
%
% Where `theta` is the rotation angle, `s` the scaling factor and `tx, ty` are
% translations in `x, y` axes respectively.
%
% Note: The RANSAC method can handle practically any ratio of outliers but
% need a threshold to distinguish inliers from outliers. The method LMedS does
% not need any threshold but it works correctly only when there are more than
% 50% of inliers.
%
% See also: cv.estimateAffine2D, cv.getAffineTransform
%

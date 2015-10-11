%FINDHOMOGRAPHY  Finds a perspective transformation between two planes
%
%    H = cv.findHomography(srcPoints, dstPoints)
%    [H, mask] = cv.findHomography(...)
%    [...] = cv.findHomography(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __srcPoints__ Coordinates of the points in the original plane, a numeric
%       array of size Nx2/1xNx2/Nx1x2 or cell array of 2-elements vectors
%       `{[x,y], ...}` (single floating-point precision).
% * __dstPoints__ Coordinates of the points in the target plane, of same size
%       and type as `srcPoints`.
%
% ## Output
% * __H__ 3x3 Homography matrix.
% * __mask__ Nx1 mask array of same length as input points, indicates inliers.
%
% ## Options
% * __Method__ Method used to computed a homography matrix. The following
%       methods are possible:
%       * __0__ a regular method using all the points. (default)
%       * __Ransac__ RANSAC-based robust method.
%       * __LMedS__ Least-Median robust method.
%       * __Rho__ PROSAC-based robust method.
% * __RansacReprojThreshold__ Maximum allowed reprojection error to treat a
%       point pair as an inlier (used in the RANSAC and RHO methods only).
%       That is, if
%       `|| dstPoints_i - convertPointsToHomogeneous(H*srcPoints_i) || > RansacReprojThreshold`
%       then the point `i` is considered an outlier. If `srcPoints` and
%       `dstPoints` are measured in pixels, it usually makes sense to set
%       this parameter somewhere in the range of 1 to 10. default 3.0.
% * __MaxIters__ The maximum number of RANSAC iterations, 2000 is the maximum
%       it can be. default 2000
% * __Confidence__ Confidence level, between 0 and 1. default 0.995
%
% The function finds and returns the perspective transformation `H` between
% the source and the destination planes:
%
%    s_i * [x_i'; y_i'; 1] ~ H * [x_i; y_i; 1]
%
% so that the back-projection error:
%
%    \sum_{i} (x_i' - (h11*x_i + h12*y_i + h13)/(h31*x_i + h32*y_i + h33))^2 +
%             (y_i' - (h21*x_i + h22*y_i + h23)/(h31*x_i + h32*y_i + h33))^2
%
% is minimized. If the parameter method is set to the default value 0, the
% function uses all the point pairs to compute an initial homography estimate
% with a simple least-squares scheme.
%
% However, if not all of the point pairs `(srcPoints_i, dstPoints_i)` fit the
% rigid perspective transformation (that is, there are some outliers), this
% initial estimate will be poor. In this case, you can use one of the three
% robust methods. The methods RANSAC, LMeDS and RHO try many different
% random subsets of the corresponding point pairs (of four pairs each),
% estimate the homography matrix using this subset and a simple
% least-square algorithm, and then compute the quality/goodness of the
% computed homography (which is the number of inliers for RANSAC or the
% median re-projection error for LMeDs). The best subset is then used to
% produce the initial estimate of the homography matrix and the mask of
% inliers/outliers.
%
% Regardless of the method, robust or not, the computed homography matrix
% is refined further (using inliers only in case of a robust method) with
% the Levenberg-Marquardt method to reduce the re-projection error even
% more.
%
% The methods RANSAC and RHO handle practically any ratio of outliers but
% need a threshold to distinguish inliers from outliers. The method LMeDS
% does not need any threshold but it works correctly only when there are
% more than 50% of inliers. Finally, if there are no outliers and the noise
% is rather small, use the default method (`Method=0`).
%
% The function is used to find initial intrinsic and extrinsic matrices.
% Homography matrix is determined up to a scale. Thus, it is normalized so
% that `h33 = 1`. Note that whenever an `H` matrix cannot be estimated, an
% empty one will be returned.
%
% See also: cv.getAffineTransform, cv.getPerspectiveTransform,
% cv.estimateRigidTransform, cv.warpPerspective, cv.perspectiveTransform
%

%FINDHOMOGRAPHY  Finds a perspective transformation between two planes
%
%     H = cv.findHomography(srcPoints, dstPoints)
%     [H, mask] = cv.findHomography(...)
%     [...] = cv.findHomography(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __srcPoints__ Coordinates of the points in the original plane, a numeric
%   array of size Nx2/1xNx2/Nx1x2 or cell array of 2-elements vectors
%   `{[x,y], ...}` (single floating-point precision).
% * __dstPoints__ Coordinates of the points in the target plane, of same size
%   and type as `srcPoints`.
%
% ## Output
% * __H__ 3x3 Homography matrix.
% * __mask__ Nx1 mask array of same length as input points, indicates inliers
%   (which points were actually used in the best computation of `H`).
%
% ## Options
% * __Method__ Method used to compute a homography matrix. The following
%   methods are possible:
%   * __0__ a regular method using all the points, i.e. the least squares
%     method (default)
%   * __Ransac__ RANSAC-based robust method.
%   * __LMedS__ Least-Median of squares robust method.
%   * __Rho__ PROSAC-based robust method, introduced in [Bazargani15].
%     (weighted RANSAC modification, faster in the case of many outliers).
% * __RansacReprojThreshold__ Maximum allowed reprojection error to treat a
%   point pair as an inlier (used in the RANSAC and RHO methods only). That
%   is, if
%   `|| dstPoints_i - convertPointsToHomogeneous(H*srcPoints_i) ||_2 > RansacReprojThreshold`
%   then the point `i` is considered as an outlier. If `srcPoints` and
%   `dstPoints` are measured in pixels, it usually makes sense to set this
%   parameter somewhere in the range of 1 to 10. default 3.0.
% * __MaxIters__ The maximum number of RANSAC iterations. default 2000
% * __Confidence__ Confidence level, between 0 and 1. default 0.995
%
% The function finds and returns the perspective transformation `H` between
% the source and the destination planes:
%
%     s_i * [x_i'; y_i'; 1] ~ H * [x_i; y_i; 1]
%
% so that the back-projection error:
%
%     sum_{i} (x_i' - (h11*x_i + h12*y_i + h13)/(h31*x_i + h32*y_i + h33))^2 +
%             (y_i' - (h21*x_i + h22*y_i + h23)/(h31*x_i + h32*y_i + h33))^2
%
% is minimized. If the parameter method is set to the default value 0, the
% function uses all the point pairs to compute an initial homography estimate
% with a simple least-squares scheme.
%
% However, if not all of the point pairs `(srcPoints_i, dstPoints_i)` fit the
% rigid perspective transformation (that is, there are some outliers), this
% initial estimate will be poor. In this case, you can use one of the three
% robust methods. The methods RANSAC, LMedS and RHO try many different
% random subsets of the corresponding point pairs (of four pairs each,
% collinear pairs are discarded), estimate the homography matrix using this
% subset and a simple least-squares algorithm, and then compute the
% quality/goodness of the computed homography (which is the number of inliers
% for RANSAC or the least median re-projection error for LMedS). The best
% subset is then used to produce the initial estimate of the homography matrix
% and the mask of inliers/outliers.
%
% Regardless of the method, robust or not, the computed homography matrix
% is refined further (using inliers only in case of a robust method) with
% the Levenberg-Marquardt method to reduce the re-projection error even
% more.
%
% The methods RANSAC and RHO handle practically any ratio of outliers but
% need a threshold to distinguish inliers from outliers. The method LMedS
% does not need any threshold but it works correctly only when there are
% more than 50% of inliers. Finally, if there are no outliers and the noise
% is rather small, use the default method (`Method=0`).
%
% The function is used to find initial intrinsic and extrinsic matrices.
% Homography matrix is determined up to a scale. Thus, it is normalized so
% that `h33 = 1`. Note that whenever an `H` matrix cannot be estimated, an
% empty one will be returned.
%
% ## References
% [Fischler81]:
% > Fischler, M. A., and R. C. Bolles. "Random sample consensus: A paradigm
% > for model fitting with applications to image analysis and automated
% > cartography", Communications of the Association for Computing Machinery
% > 24 (1981): 381-395.
%
% [Rousseeuw84]:
% > Rousseeuw, P. J. "Least median of squares regression", Journal of the
% > American Statistical Association, 79 (1984): 871-880.
%
% [Inui03]:
% > Inui, K., S. Kaneko, and S. Igarashi. "Robust Line Fitting using LMedS
% > Clustering", Systems and Computers in Japan 34 (2003): 92-100.
%
% [Bazargani15]:
% > Hamid Bazargani, Olexa Bilaniuk, and Robert Laganiere. "A fast and robust
% > homography scheme for real-time planar target detection". Journal of
% > Real-Time Image Processing (2015): 1-20.
%
% See also: cv.getAffineTransform, cv.estimateAffine2D,
% cv.estimateAffinePartial2D, cv.getPerspectiveTransform,
% cv.estimateRigidTransform, cv.warpPerspective, cv.perspectiveTransform
%

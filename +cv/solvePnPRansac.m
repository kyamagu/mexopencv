%SOLVEPNPRANSAC  Finds an object pose from 3D-2D point correspondences using the RANSAC scheme
%
%     [rvec, tvec, success, inliers] = cv.solvePnPRansac(objectPoints, imagePoints, cameraMatrix)
%     [...] = cv.solvePnPRansac(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ Array of object points in the object coordinate space,
%   1xNx3/Nx1x3 or Nx3 array, where `N` is the number of points, or cell
%   array of length `N` of 3-element vectors can be also passed here
%   `{[x,y,z], ...}`.
% * __imagePoints__ Array of corresponding image points, 1xNx2/Nx1x2 or Nx2
%   array, where `N` is the number of points, or cell array of length `N` of
%   2-element vectors can be also passed here `{[x,y], ...}`.
% * __cameraMatrix__ Input camera matrix `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
%
% ## Output
% * __rvec__ Output rotation vector (see cv.Rodrigues) that, together with
%   `tvec`, brings points from the model coordinate system to the camera
%   coordinate system.
% * __tvec__ Output translation vector.
% * __success__ success logical flag.
% * __inliers__ Output vector that contains indices (zero-based) of inliers in
%   `objectPoints` and `imagePoints`.
%
% ## Options
% * __DistCoeffs__ Input vector of distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4,taux,tauy]` of 4, 5, 8, 12 or 14
%   elements. If the vector is empty, the zero distortion coefficients are
%   assumed. default empty.
% * __Rvec__ Initial `rvec`. Not set by default.
% * __Tvec__ Initial `tvec`. Not set by default.
% * __UseExtrinsicGuess__ Parameter used for `Method='Iterative'`. If true,
%   the function uses the provided `rvec` and `tvec` values as initial
%   approximations of the rotation and translation vectors, respectively, and
%   further optimizes them. default false.
% * __IterationsCount__ Number of iterations. default 100.
% * __ReprojectionError__ Inlier threshold value used by the RANSAC procedure.
%   The parameter value is the maximum allowed distance between the observed
%   and computed point projections to consider it an inlier. default 8.0.
% * __Confidence__ The probability that the algorithm produces a useful result.
%   default 0.99
% * __Method__ Method for solving the PnP problem. See cv.solvePnP.
%   default 'Iterative'
%
% The function estimates an object pose given a set of object points, their
% corresponding image projections, as well as the camera matrix and the
% distortion coefficients. This function finds such a pose that minimizes
% reprojection error, that is, the sum of squared distances between the
% observed projections `imagePoints` and the projected (using cv.projectPoints)
% `objectPoints`. The use of RANSAC makes the function resistant to outliers.
%
% Note: The default method used to estimate the camera pose for the Minimal
% Sample Sets step is `EPnP`. Exceptions: if you choose `P3P` or `AP3P`, these
% methods will be used; if the number of input points is equal to 4, `P3P` is
% used.
%
% The method used to estimate the camera pose using all the inliers is defined
% by the flags parameters unless it is equal to `P3P` or `AP3P`. In this case,
% the method `EPnP` will be used instead.
%
% See also: cv.solvePnP, estimateWorldCameraPose
%

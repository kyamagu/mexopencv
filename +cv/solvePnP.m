%SOLVEPNP  Finds an object pose from 3D-2D point correspondences
%
%    [rvec, tvec, success] = cv.solvePnP(objectPoints, imagePoints, cameraMatrix)
%    [...] = cv.solvePnP(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ Array of object points in the object coordinate space,
%       1xNx3/Nx1x3 or Nx3 array, where `N` is the number of points, or cell
%       array of length `N` of 3-element vectors can be also passed here
%       `{[x,y,z], ...}`.
% * __imagePoints__ Array of corresponding image points, 1xNx2/Nx1x2 or
%       Nx2 array, where `N` is the number of points, or cell array of
%       length `N` of 2-element vectors can be also passed here
%       `{[x,y], ...}`.
% * __cameraMatrix__ Input camera matrix `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
%
% ## Output
% * __rvec__ Output rotation vector (see cv.Rodrigues) that, together with
%       `tvec`, brings points from the model coordinate system to the
%       camera coordinate system.
% * __tvec__ Output translation vector.
% * __success__ success logical flag.
%
% ## Options
% * __DistCoeffs__ Input vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8, or 12 elements.
%       If the vector is empty, the zero distortion coefficients are assumed.
%       default empty.
% * __Rvec__ Initial `rvec`. Not set by default.
% * __Tvec__ Initial `tvec`. Not set by default.
% * __UseExtrinsicGuess__ Parameter used for `Method='Iterative'`. If true,
%       the function uses the provided `rvec` and `tvec` values as initial
%       approximations of the rotation and translation vectors, respectively,
%       and further optimizes them. default false.
% * __Method__ Method for solving the PnP problem. One of the following:
%       * __Iterative__ Iterative method is based on Levenberg-Marquardt
%             optimization. In this case the function finds such a pose that
%             minimizes reprojection error, that is the sum of squared distances
%             between the observed projections `imagePoints` and the projected
%             (using cv.projectPoints) `objectPoints`. This is the default.
%       * __P3P__ Method is based on the paper [1]. In this case the
%             function requires exactly four object and image points.
%       * __EPnP__ Method has been introduced in the paper [2].
%       * __DLS__ Method is based on the paper of [3].
%       * __UPnP__ Method is based on the paper of [4]. In this case the
%             function also estimates the parameters `fx` and `fy` assuming
%             that both have the same value. Then the `cameraMatrix` is
%             updated with the estimated focal length.
%
% The function estimates the object pose given a set of object points,
% their corresponding image projections, as well as the camera matrix and
% the distortion coefficients.
%
% ## References
% [1]:
% > X.S. Gao, X.-R. Hou, J. Tang, H.-F. Chang; "Complete Solution
% > Classification for the Perspective-Three-Point Problem",
% > IEEE Trans. on PAMI, vol. 25, No. 8, August 2003.
%
% [2]:
% > F.Moreno-Noguer, V.Lepetit and P.Fua;
% > "EPnP: Efficient Perspective-n-Point Camera Pose Estimation".
%
% [3]:
% > Joel A. Hesch and Stergios I. Roumeliotis.
% > "A Direct Least-Squares (DLS) Method for PnP".
%
% [4]:
% > A.Penate-Sanchez, J.Andrade-Cetto, F.Moreno-Noguer.
% > "Exhaustive Linearization for Robust Camera Pose and Focal Length Estimation".
%
% See also: cv.solvePnPRansac
%

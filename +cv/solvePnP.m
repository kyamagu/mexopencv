%SOLVEPNP  Finds an object pose from 3D-2D point correspondences
%
%     [rvec, tvec, success] = cv.solvePnP(objectPoints, imagePoints, cameraMatrix)
%     [...] = cv.solvePnP(..., 'OptionName', optionValue, ...)
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
% * __Method__ Method for solving the PnP problem. One of the following:
%   * __Iterative__ Iterative method is based on Levenberg-Marquardt
%     optimization. In this case the function finds such a pose that minimizes
%     reprojection error, that is the sum of squared distances between the
%     observed projections `imagePoints` and the projected (using
%     cv.projectPoints) `objectPoints`. This is the default.
%   * __P3P__ Method is based on the paper [gao2003complete]. In this case the
%     function requires exactly four object and image points.
%   * __AP3P__ Method is based on the paper [Ke17]. In this case the function
%     requires exactly four object and image points.
%   * __EPnP__ Method has been introduced in the paper [morenoepnp] and
%     [lepetit2009epnp].
%   * __DLS__ Method is based on the paper [hesch2011direct].
%   * __UPnP__ Method is based on the paper [penate2013exhaustive]. In this
%     case the function also estimates the parameters `fx` and `fy` assuming
%     that both have the same value. Then the `cameraMatrix` is updated with
%     the estimated focal length.
%
% The function estimates the object pose given a set of object points,
% their corresponding image projections, as well as the camera matrix and
% the distortion coefficients. See the figure below (more precisely, the
% X-axis of the camera frame is pointing to the right, the Y-axis downward and
% the Z-axis forward):
%
% ![image](https://docs.opencv.org/3.4.0/pnp.jpg)
%
% Points expressed in the world frame `X_w` are projected into the image plane
% `[u,v]` using the perspective projection model `Pi` and the camera intrinsic
% parameters matrix `A`:
%
%     [u; v; 1] = A * Pi * M_w^c * [X_w; Y_w; Z_w; 1]
%
%     [u; v; 1] = [fx 0 cx; 0 fy cy; 0 0 1] *
%                 [1 0 0 0; 0 1 0 0; 0 0 1 0] *
%                 [r11 r12 r13 tx; r21 r22 r23 ty; r31 r32 r33 tz] *
%                 [X_w; Y_w; Z_w; 1]
%
% The estimated pose is thus the rotation (`rvec`) and the translation (`tvec`)
% vectors that allow to transform a 3D point expressed in the world frame into
% the camera frame:
%
%     [X_c; Y_c; Z_c; 1] = M_w^c * [X_w; Y_w; Z_w; 1]
%
%     [X_c; Y_c; Z_c; 1] = [r11 r12 r13 tx; r21 r22 r23 ty; r31 r32 r33 tz] *
%                          [X_w; Y_w; Z_w; 1]
%
% ### Notes
%
% * The methods `DLS` and `UPnP` cannot be used as the current implementations
%   are unstable and sometimes give completely wrong results. If you pass one
%   of these two flags, `EPnP` method will be used instead.
%
% * The minimum number of points is 4 in the general case. In the case of
%   `P3P` and `AP3P` methods, it is required to use exactly 4 points (the
%   first 3 points are used to estimate all the solutions of the P3P problem,
%   the last one is used to retain the best solution that minimizes the
%   reprojection error).
%
% * With `Iterative` method and `UseExtrinsicGuess=true`, the minimum number
%   of points is 3 (3 points are sufficient to compute a pose but there are up
%   to 4 solutions). The initial solution should be close to the global
%   solution to converge.
%
% ## References
% [gao2003complete]:
% > X.S. Gao, X.R. Hou, J. Tang, H.F. Chang; "Complete Solution
% > Classification for the Perspective-Three-Point Problem",
% > IEEE Trans. on PAMI, vol. 25, No. 8, p. 930-943, August 2003.
%
% [Ke17]:
% > T. Ke, S. Roumeliotis; "An Efficient Algebraic Solution to the
% > Perspective-Three-Point Problem", IEEE Conference on Computer Vision and
% > Pattern Recognition (CVPR), 2017
% > [PDF](https://arxiv.org/pdf/1701.08237.pdf)
%
% [morenoepnp]:
% > F. Moreno-Noguer, V. Lepetit and P. Fua;
% > "EPnP: Efficient Perspective-n-Point Camera Pose Estimation".
%
% [lepetit2009epnp]:
% > V. Lepetit, F. Moreno-Noguer, P. Fua;
% > "EPnP: An accurate O(n) solution to the PnP problem".
% > IJCV, vol. 81, No. 2, p. 155-166, 2009
%
% [hesch2011direct]:
% > Joel A. Hesch and Stergios I. Roumeliotis.
% > "A Direct Least-Squares (DLS) Method for PnP".
% > IEEE International Conference on Computer Vision, p. 383-390, 2011.
%
% [penate2013exhaustive]:
% > A. Penate-Sanchez, J. Andrade-Cetto, F. Moreno-Noguer; "Exhaustive
% > Linearization for Robust Camera Pose and Focal Length Estimation".
% > IEEE Trans. on PAMI, vol. 35, No. 10, p. 2387-2400, 2013.
%
% See also: cv.solvePnPRansac, estimateWorldCameraPose, cameraPoseToExtrinsics,
%  extrinsicsToCameraPose
%

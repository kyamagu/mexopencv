%SOLVEPNP  Finds an object pose from 3D-2D point correspondences
%
%    [rvec, tvec] = cv.solvePnP(objectPoints, imagePoints, cameraMatrix)
%    [rvec, tvec] = cv.solvePnP(objectPoints, imagePoints, cameraMatrix, distCoeffs)
%    [...] = cv.solvePnP(..., distCoeffs, 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ Array of object points in the object coordinate space,
%        1xNx3/Nx1x3 or 3xN/Nx3 array, where N is the number of points, or
%        cell array of 3-element vectors can be also passed here.
% * __imagePoints__ Array of corresponding image points, 1xNx2/Nx1x2 or
%        2xN/Nx2 array, where N is the number of points, or cell array of
%        2-element vectors can be also passed here.
% * __cameraMatrix__ Input camera matrix `A = [fx,0,cx; 0,fy,cy; 0,0,1]`.
% * __distCoeffs__ Input vector of distortion coefficients [k1,k2,p1,p2,k3,
%        k4,k5,k6] of 4, 5, or 8 elements. If the vector is empty, the
%        zero distortion coefficients are assumed.
%
% ## Output
% * __rvec__ Output rotation vector (see cv.Rodrigues) that, together with
%        `tvec`, brings points from the model coordinate system to the
%        camera coordinate system.
% * __tvec__ Output translation vector.
%
% ## Options
% * __Rvec__ Initial `rvec`. default empty.
% * __Tvec__ Initial `tvec`. default empty.
% * __UseExtrinsicGuess__ If true, the function uses the provided `rvec`
%        and `tvec` values as initial approximations of the rotation and
%        translation vectors, respectively, and further optimizes them.
%        default false.
% * __Flags__ Method for solving the PnP problem. One of the following:
%     * __Iterative__ Iterative method is based on Levenberg-Marquardt
%         optimization. In this case the function finds such a pose that
%         minimizes reprojection error, that is the sum of squared distances
%         between the observed projections `imagePoints` and the projected
%         (using cv.projectPoints) `objectPoints`. This is the default.
%     * __P3P__ Method is based on the paper [1]. In this case the
%         function requires exactly four object and image points.
%     * __EPnP__ Method has been introduced in the paper [2].
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
%
% The function estimates the object pose given a set of object points,
% their corresponding image projections, as well as the camera matrix and
% the distortion coefficients.
%
% See also cv.solvePnPRansac
%

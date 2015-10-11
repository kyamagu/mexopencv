%UNDISTORTPOINTS  Computes the ideal point coordinates from the observed point coordinates
%
%    dst = cv.undistortPoints(src, cameraMatrix, distCoeffs)
%    dst = cv.undistortPoints(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Observed point coordinates. An Nx2, 1xNx2, or Nx1x2 array (either
%       `single` or `double`).
% * __cameraMatrix__ Input camera matrix `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __distCoeffs__ Input vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8, or 12 elements.
%       If the vector is empty, the zero distortion coefficients are assumed.
%
% ## Output
% * __dst__ Output ideal point coordinates after undistortion and reverse
%       perspective transformation. If matrix `P` is identity or omitted,
%       `dst` will contain normalized point coordinates. Same size and type as
%       the input points `src`.
%
% ## Options
% * __R__ Rectification transformation in the object space (3x3 matrix). `R1`
%       or `R2` computed by cv.stereoRectify can be passed here. If the matrix
%       is empty, the identity transformation is used. default empty
% * __P__ New camera matrix (3x3) or new projection matrix (3x4). `P1` or `P2`
%       computed by cv.stereoRectify can be passed here. If the matrix is
%       empty, the identity new camera matrix is used. default empty
%
% The function is similar to cv.undistort and cv.initUndistortRectifyMap but
% it operates on a sparse set of points instead of a raster image. Also the
% function performs a reverse transformation to cv.projectPoints. In case of a
% 3D object, it does not reconstruct its 3D coordinates, but for a planar
% object, it does, up to a translation vector, if the proper `R` is specified.
%
%    % (u,v) is the input point, (up, vp) is the output point
%    % camera_matrix = [fx 0 cx; 0 fy cy; 0 0 1]
%    % P = [fxp 0 cxp tx; 0 fyp cyp ty; 0 0 tz]
%    xpp = (u - cx)/fx
%    ypp = (v - cy)/fy
%    (xp,yp) = cv.undistort(xpp, ypp, dist_coeffs)
%    [X,Y,W]' = R*[xp yp 1]'
%    x = X/W, y = Y/W
%    up = x*fxp + cxp
%    vp = y*fyp + cyp
%
% where cv.undistort is an approximate iterative algorithm that estimates the
% normalized original point coordinates out of the normalized distorted point
% coordinates ("normalized" means that the coordinates do not depend on the
% camera matrix).
%
% The function can be used for both a stereo camera head or a monocular camera
% (when `R` is empty).
%
% See also: cv.undistort, cv.calibrateCamera, undistortPoints
%

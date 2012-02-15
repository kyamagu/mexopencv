%UNDISTORTPOINTS  Computes the ideal point coordinates from the observed point coordinates
%
%    dst = cv.undistortPoints(src, cameraMatrix, distCoeffs)
%    dst = cv.undistortPoints(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Observed point coordinates, 1xNx2 or 1xNx2.
% * __cameraMatrix__ Input camera matrix A = [fx,0,cx;0,fy,cy;0,0,1].
% * __distCoeffs__ Input vector of distortion coefficients [k1,k2,p1,p2,k3,k4,k5,
%        k6] of 4, 5, or 8 elements. If the vector is empty, the zero distortion
%        coefficients are assumed.
%
% ## Output
% * __dst__ Output ideal point coordinates after undistortion and reverse
%        perspective transformation.
%
% ## Options
% * __R__ Rectification transformation in the object space (3x3 matrix). R1 or
%        R2 computed by cv.stereoRectify can be passed here. If the matrix is
%        empty, the identity transformation is used.
% * __P__ New camera matrix (3x3) or new projection matrix (3x4). P1 or P2
%        computed by cv.stereoRectify can be passed here. If the matrix is
%        empty, the identity new camera matrix is used.
%
% The function is similar to cv.undistort and cv.initUndistortRectifyMap but it
% operates on a sparse set of points instead of a raster image. Also the
% function performs a reverse transformation to cv.projectPoints. In case of a
% 3D object, it does not reconstruct its 3D coordinates, but for a planar
% object, it does, up to a translation vector, if the proper R is specified.
%
%    % (u,v) is the input point, (u', v') is the output point
%    % camera_matrix=[fx 0 cx; 0 fy cy; 0 0 1]
%    % P=[fx' 0 cx' tx; 0 fy' cy' ty; 0 0 1 tz]
%    x" = (u - cx)/fx
%    y" = (v - cy)/fy
%    (x',y') = cv.undistort(x",y",dist_coeffs)
%    [X,Y,W]T = R*[x' y' 1]T
%    x = X/W, y = Y/W
%    u' = x*fx' + cx'
%    v' = y*fy' + cy',
%
% where cv.undistort is an approximate iterative algorithm that estimates the
% normalized original point coordinates out of the normalized distorted point
% coordinates ("normalized" means that the coordinates do not depend on the
% camera matrix).
%
% The function can be used for both a stereo camera head or a monocular camera
% (when R is empty).
%
% See also cv.undistortPoints cv.calibrateCamera
%

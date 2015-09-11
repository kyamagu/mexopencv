%INITUNDISTORTRECTIFYMAP  Computes the undistortion and rectification transformation map
%
%    [map1, map2] = cv.initUndistortRectifyMap(cameraMatrix, distCoeffs, newCameraMatrix, siz)
%    [...] = cv.initUndistortRectifyMap(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __cameraMatrix__ Input camera matrix `A = [f_x 0 c_x; 0 f_y c_y; 0 0 1]`
% * __distCoeffs__ Input vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8, or 12 elements. If
%       the vector is empty, the zero distortion coefficients are assumed.
% * __newCameraMatrix__ New camera matrix
%       `Ap = [fp_x 0 cp_x; 0 fp_y cp_y; 0 0 1]`
% * __siz__ Undistorted image size `[w,h]`.
%
% ## Output
% * __map1__ The first output map. See `M1Type`.
% * __map2__ The second output map. See `M1Type`.
%
% ## Options
% * __R__ Optional rectification transformation in the object space (3x3
%       matrix). `R1` or `R2`, computed by cv.stereoRectify can be passed
%       here. If the matrix is empty, the identity transformation is assumed.
%       default empty
% * __M1Type__ Type of the first output map, default -1 (equivalent to
%       `int16`). See cv.convertMaps. Accepted types are:
%       * __int16__ first output map is a MxNx2 `int16` array, second output
%             map is MxNx1 `uint16` (fixed-point representation).
%       * __single1__ first output map is a MxNx1 `single` matrix, second
%             output map is MxNx1 `single` (separate floating-point
%             representation).
%       * __single2__ first output map is a MxNx2 `single` matrix, second
%             output map is empty (combined floating-point representation).
%
% The function computes the joint undistortion and rectification
% transformation and represents the result in the form of maps for
% cv.remap. The undistorted image looks like original, as if it is captured
% with a camera using the camera matrix `newCameraMatrix` and zero distortion.
% In case of a monocular camera, `newCameraMatrix` is usually equal to
% `cameraMatrix`, or it can be computed by cv.getOptimalNewCameraMatrix for a
% better control over scaling. In case of a stereo camera, `newCameraMatrix`
% is normally set to `P1` or `P2` computed by cv.stereoRectify.
%
% Also, this new camera is oriented differently in the coordinate space,
% according to `R`. That, for example, helps to align two heads of a stereo
% camera so that the epipolar lines on both images become horizontal and
% have the same y-coordinate (in case of a horizontally aligned stereo
% camera).
%
% The function actually builds the maps for the inverse mapping algorithm
% that is used by cv.remap. That is, for each pixel `(u,v)` in the
% destination (corrected and rectified) image, the function computes the
% corresponding coordinates in the source image (that is, in the original
% image from camera). The following process is applied:
%
%    x = (u - cp_x) / fp_x
%    y = (v - cp_y) / fp_y
%    [X Y Z]' = inv(R) * [x y 1]'
%    xp = X / W
%    yp = Y / W
%    xpp = xp*(1 + k1*r^2 + k2*r^4 + k3*r^6) + 2*p1*xp*yp + p2*(r^2 + 2*xp^2)
%    ypp = yp*(1 + k1*r^2 + k2*r^4 + k3*r^6) + p1*(r^2 + 2*yp^2) + 2*p2*xp*yp
%    map_x(u,v) = xpp * f_x + c_x
%    map_y(u,v) = ypp * f_y + c_y
%
% where `k1`, `k2`, `p1`, `p2`, `k3` are the distortion coefficients.
%
% In case of a stereo camera, this function is called twice: once for each
% camera head, after cv.stereoRectify, which in its turn is called after
% cv.stereoCalibrate. But if the stereo camera was not calibrated, it is still
% possible to compute the rectification transformations directly from the
% fundamental matrix using cv.stereoRectifyUncalibrated. For each camera, the
% function computes homography `H` as the rectification transformation in a
% pixel domain, not a rotation matrix `R` in 3D space. `R`  can be computed
% from `H` as
%
%    R = inv(cameraMatrix) * H * cameraMatrix
%
% where `cameraMatrix` can be chosen arbitrarily.
%
% See also: cv.remap, cv.convertMaps, cv.getOptimalNewCameraMatrix,
%  cv.stereoRectify, cv.stereoCalibrate, cv.stereoRectifyUncalibrated
%

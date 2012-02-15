%INITUNDISTORTRECTIFYMAP  Computes the undistortion and rectification transformation map
%
%    [map1, map2] = cv.initUndistortRectifyMap(cameraMatrix, distCoeffs, newCameraMatrix, siz)
%    [...] = cv.initCameraMatrix2D(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __cameraMatrix__ Input camera matrix A = [fx,0,cx;0,fy,cy;0,0,1]
% * __distCoeffs__ Input vector of distortion coefficients [k1, k2, p1, p2,
%     k3, k4, k5, k6] of 4, 5, or 8 elements. If the vector is NULL/empty,
%     the zero distortion coefficients are assumed.
% * __newCameraMatrix__ New camera matrix A' = [fx',0,cx';0,fy',cy';0,0,1]
% * __siz__ Undistorted image size.
%
% ## Output
% * __map1__ The first output map.
% * __map2__ The second output map.
%
% ## Options
% * __R__ rectification transformation in the object space (3x3 matrix). R1
%     or R2 , computed by cv.stereoRectify can be passed here. If the
%     matrix is empty, the identity transformation is assumed. In
%     cvInitUndistortMap R assumed to be an identity matrix.
% * __M1Type__ Type of the first output map that can be 'uint16' or
%     'single'. See cv.convertMaps.
%
% The function computes the joint undistortion and rectification
% transformation and represents the result in the form of maps for
% cv.remap. The undistorted image looks like original, as if it is captured
% with a camera using the camera matrix = newCameraMatrix and zero
% distortion. In case of a monocular camera, newCameraMatrix is usually
% equal to cameraMatrix, or it can be computed by
% cv.getOptimalNewCameraMatrix for a better control over scaling. In case
% of a stereo camera, newCameraMatrix is normally set to P1 or P2 computed
% by cv.stereoRectify.
%
% Also, this new camera is oriented differently in the coordinate space,
% according to R . That, for example, helps to align two heads of a stereo
% camera so that the epipolar lines on both images become horizontal and
% have the same y- coordinate (in case of a horizontally aligned stereo
% camera).
%
% The function actually builds the maps for the inverse mapping algorithm
% that is used by cv.remap. That is, for each pixel (u,v) in the
% destination (corrected and rectified) image, the function computes the
% corresponding coordinates in the source image (that is, in the original
% image from camera).
%
% In case of a stereo camera, this function is called twice: once for each
% camera head, after cv.stereoRectify, which in its turn is called after
% cv.stereoCalibrate. But if the stereo camera was not calibrated, it is
% still possible to compute the rectification transformations directly from
% the fundamental matrix using cv.stereoRectifyUncalibrated. For each
% camera, the function computes homography H as the rectification
% transformation in a pixel domain, not a rotation matrix R in 3D space. R
% can be computed from H as
%
%    R = cameraMatrix^-1 * H * cameraMatrix
%
% where cameraMatrix can be chosen arbitrarily.
%
% See also cv.remap cv.convertMaps cv.getOptimalNewCameraMatrix
% cv.stereoRectify cv.stereoCalibrate cv.stereoRectifyUncalibrated
%

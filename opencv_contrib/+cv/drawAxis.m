%DRAWAXIS  Draw coordinate system axis from pose estimation
%
%     img = cv.drawAxis(img, cameraMatrix, distCoeffs, rvec, tvec, length)
%
% ## Input
% * __img__ input image. It must have 1 or 3 channels. In the output, the
%   number of channels is not altered.
% * __cameraMatrix__ input 3x3 floating-point camera matrix
%   `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __distCoeffs__ vector of distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
% * __rvec__ rotation vector of the coordinate system that will be drawn.
% * __tvec__ translation vector of the coordinate system that will be drawn.
% * __length__ length of the painted axis in the same unit as `tvec`
%   (usually in meters).
%
% ## Output
% * __img__ output image.
%
% Given the pose estimation of a marker or board, this function draws the
% axis of the world coordinate system, i.e. the system centered on the
% marker/board. Useful for debugging purposes.
%
% See also: cv.estimatePoseBoard, cv.estimatePoseSingleMarkers,
%  cv.estimatePoseCharucoBoard, cv.Rodrigues, cv.line, cv.projectPoints
%

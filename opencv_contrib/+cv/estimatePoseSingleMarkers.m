%ESTIMATEPOSESINGLEMARKERS  Pose estimation for single markers
%
%     [rvecs, tvecs] = cv.estimatePoseSingleMarkers(corners, markerLength, cameraMatrix, distCoeffs)
%     [rvecs, tvecs, objPoints] = cv.estimatePoseSingleMarkers(...)
%
% ## Input
% * __corners__ cell array of already detected markers corners. For each
%   marker, its four corners are provided, (e.g `{{[x,y],..}, ..}`). The order
%   of the corners should be clockwise.
% * __markerLength__ the length of the markers' side. The returning
%   translation vectors will be in the same unit. Normally, unit is meters.
% * __cameraMatrix__ input 3x3 floating-point camera matrix
%   `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __distCoeffs__ vector of distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
%
% ## Output
% * __rvecs__ cell array of output rotation vectors (e.g. `{[x,y,z], ...}`).
%   Each element in `rvecs` corresponds to the specific marker in `corners`.
% * __tvecs__ cell array of output translation vectors (e.g. `{[x,y,z], ...}`).
%   Each element in `tvecs` corresponds to the specific marker in `corners`.
% * __objPoints__ optional output, array of object points of the marker four
%   corners (object points for the system centered in a single marker given
%   the marker length, see explanation below).
%
% This function receives the detected markers and returns their pose
% estimation respect to the camera individually. So for each marker, one
% rotation and translation vector is returned. The returned transformation is
% the one that transforms points from each marker coordinate system to the
% camera coordinate system. The marker corrdinate system is centered on the
% middle of the marker, with the Z axis perpendicular to the marker plane.
% The coordinates of the four corners of the marker in its own coordinate
% system are:
%
%     (-markerLength/2,  markerLength/2, 0),
%     ( markerLength/2,  markerLength/2, 0),
%     ( markerLength/2, -markerLength/2, 0),
%     (-markerLength/2, -markerLength/2, 0)
%
% See also: cv.detectMarkers, cv.estimatePoseBoard, cv.Rodrigues, cv.solvePnP
%

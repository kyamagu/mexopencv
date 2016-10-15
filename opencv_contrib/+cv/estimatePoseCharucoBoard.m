%ESTIMATEPOSECHARUCOBOARD  Pose estimation for a ChArUco board given some of their corners
%
%    [rvec, tvec, valid] = cv.estimatePoseCharucoBoard(charucoCorners, charucoIds, board, cameraMatrix, distCoeffs)
%
% ## Input
% * __charucoCorners__ cell array of detected charuco corners `{[x,y], ..}`.
% * __charucoIds__ vector of identifiers for each corner in `charucoCorners`
%       (0-based).
% * __board__ layout of ChArUco board.
% * __cameraMatrix__ input 3x3 floating-point camera matrix
%       `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __distCoeffs__ vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
%
% ## Output
% * __rvec__ Output vector corresponding to the rotation vector of the board.
% * __tvec__ Output vector corresponding to the translation vector of the
%       board.
% * __valid__ The function checks if the input corners are enough and valid
%       to perform pose estimation. If pose estimation is valid, returns true,
%       else returns false.
%
% This function estimates a Charuco board pose from some detected corners.
%
% See also: cv.interpolateCornersCharuco, cv.estimatePoseBoard, cv.drawAxis,
%  cv.drawCharucoBoard, cv.Rodrigues, cv.solvePnP
%

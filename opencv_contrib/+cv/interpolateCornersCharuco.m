%INTERPOLATECORNERSCHARUCO  Interpolate position of ChArUco board corners
%
%     [charucoCorners, charucoIds, num] = cv.interpolateCornersCharuco(markerCorners, markerIds, img, board)
%     [...] = cv.interpolateCornersCharuco(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __markerCorners__ cell array of already detected markers corners. For each
%   marker, its four corners are provided, (e.g `{{[x,y],..}, ..}`). The order
%   of the corners should be clockwise.
% * __markerIds__ vector of identifiers for each marker in `markerCorners`
%   (0-based).
% * __img__ input image necesary for corner refinement (8-bit grayscale or
%   color). Note that markers are not detected and should be sent in
%   `markerCorners` and `markerIds` parameters.
% * __board__ layout of ChArUco board.
%
% ## Output
% * __charucoCorners__ interpolated chessboard corners `{[x,y], ..}`.
% * __charucoIds__ interpolated chessboard corners identifiers (0-based).
% * __num__ the number of interpolated corners.
%
% ## Options
% * __CameraMatrix__ optional 3x3 floating-point camera matrix
%   `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __DistCoeffs__ optional vector of distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
% * __MinMarkers__ number of adjacent markers that must be detected to return
%   a charuco corner. default 2
%
% This function receives the detected markers and returns the 2D position of
% the chessboard corners from a ChArUco board using the detected Aruco
% markers. If camera parameters are provided, the process is based in an
% approximated pose estimation, else it is based on local homography. Only
% visible corners are returned. For each corner, its corresponding identifier
% is also returned in `charucoIds`.
%
% See also: cv.detectMarkers, cv.estimatePoseCharucoBoard, cv.drawCharucoBoard,
%  cv.drawDetectedCornersCharuco, cv.projectPoints, cv.getPerspectiveTransform,
%  cv.cornerSubPix
%

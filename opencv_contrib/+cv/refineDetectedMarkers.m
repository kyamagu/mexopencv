%REFINEDETECTEDMARKERS  Refind not detected markers based on the already detected and the board layout
%
%     [detectedCorners, detectedIds, rejectedCorners] = cv.refineDetectedMarkers(img, board, detectedCorners, detectedIds, rejectedCorners)
%     [detectedCorners, detectedIds, rejectedCorners, recoveredIdxs] = cv.refineDetectedMarkers(...)
%     [...] = cv.refineDetectedMarkers(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image (8-bit grayscale or color).
% * __board__ layout of markers in the board.
% * __detectedCorners__ cell array of already detected marker corners
%   `{{[x,y],..}, ..}`.
% * __detectedIds__ vector of already detected marker identifiers (0-based).
% * __rejectedCorners__ cell array of rejected candidates during the marker
%   detection process `{{[x,y],..}, ..}`.
%
% ## Output
% * __detectedCorners__ output refined marker corners.
% * __detectedIds__ output refined marker identifiers
% * __rejectedCorners__ output refined rejected corners.
% * __recoveredIdxs__ Optional array that returns the indexes of the recovered
%   candidates in the original `rejectedCorners` array.
%
% ## Options
% * __CameraMatrix__ optional input 3x3 floating-point camera matrix
%   `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __DistCoeffs__ optional vector of distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
% * __MinRepDistance__ minimum distance between the corners of the rejected
%   candidate and the reprojected marker in order to consider it as a
%   correspondence. default 10.0
% * __ErrorCorrectionRate__ rate of allowed erroneous bits respect to the
%   error correction capability of the used dictionary. -1 ignores the error
%   correction step. default 3.0
% * __CheckAllOrders__ Consider the four posible corner orders in the
%   `rejectedCorners` array. If it set to false, only the provided corner
%   order is considered (default true).
% * __DetectorParameters__ marker detection parameters.
%
% This function tries to find markers that were not detected in the basic
% cv.detectMarkers function. First, based on the current detected marker and
% the board layout, the function interpolates the position of the missing
% markers. Then it tries to find correspondence between the reprojected
% markers and the rejected candidates based on the `minRepDistance` and
% `errorCorrectionRate` parameters. If camera parameters and distortion
% coefficients are provided, missing markers are reprojected using
% cv.projectPoints function. If not, missing marker projections are
% interpolated using global homography, and all the marker corners in the
% board must have the same Z coordinate.
%
% See also: cv.detectMarkers, cv.estimatePoseBoard, cv.findHomography,
%  cv.perspectiveTransform
%

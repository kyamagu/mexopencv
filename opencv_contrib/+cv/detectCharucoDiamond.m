%DETECTCHARUCODIAMOND  Detect ChArUco Diamond markers
%
%     [diamondCorners, diamondIds] = cv.detectCharucoDiamond(img, markerCorners, markerIds, squareMarkerLengthRate)
%     [...] = cv.detectCharucoDiamond(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image necessary for corner subpixel (8-bit grayscale or
%   color).
% * __markerCorners__ cell array of detected marker corners from
%   cv.detectMarkers function `{{[x,y],..}, ..}`.
% * __markerIds__ vector of marker ids in `markerCorners` (0-based).
% * __squareMarkerLengthRate__ rate between square and marker length:
%   `squareMarkerLengthRate = squareLength/markerLength`. The real units are
%   not necessary.
%
% ## Output
% * __diamondCorners__ output list of detected diamond corners (4 corners per
%   diamond). The order is the same than in marker corners: top left, top
%   right, bottom right and bottom left. Similar format than the corners
%   returned by cv.detectMarkers (e.g `{{[x y],..}, ..}`).
% * __diamondIds__ ids of the diamonds in `diamondCorners` (0-based). The id
%   of each diamond is in fact a vector of four integers, so each diamond has
%   4 ids, which are the ids of the aruco markers composing the diamond.
%
% ## Options
% * __CameraMatrix__ Optional 3x3 camera calibration matrix
%   `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __DistCoeffs__ Optional vector of camera distortion coefficients
%   `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8 or 12 elements.
%
% This function detects Diamond markers from the previous detected ArUco
% markers. The diamonds are returned in the `diamondCorners` and `diamondIds`
% parameters. If camera calibration parameters are provided, the diamond
% search is based on reprojection. If not, diamond search is based on
% homography. Homography is faster than reprojection but can slightly reduce
% the detection rate.
%
% See also: cv.detectMarkers, cv.interpolateCornersCharuco,
%  cv.drawDetectedDiamonds
%

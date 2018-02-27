%FISHEYEUNDISTORTPOINTS  Undistorts 2D points using fisheye model
%
%     undistorted = cv.fisheyeUndistortPoints(distorted, K, D);
%     [...] = cv.fisheyeUndistortPoints(..., 'OptionName',optionValue, ...);
%
% ## Input
% * __distorted__ Object points. An Nx2, 1xNx2, or Nx1x2 array, where N is the
%   number of points in the view.
% * __K__ Camera matrix 3x3, `K = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __D__ Input vector of distortion coefficients `[k1,k2,k3,k4]`.
%
% ## Output
% * __undistorted__ Output array of image points.
%
% ## Options
% * __R__ Rectification transformation in the object space
%   (3x3 matrix or 1x3/3x1 vector).
% * __P__ New camera matrix (3x3) or new projection matrix (3x4).
%
% See also: cv.fisheyeUndistortImage, cv.undistortPoints
%

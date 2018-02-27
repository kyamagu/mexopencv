%FISHEYEDISTORTPOINTS  Distorts 2D points using fisheye model
%
%     distorted = cv.fisheyeDistortPoints(undistorted, K, D);
%     [...] = cv.fisheyeDistortPoints(..., 'OptionName',optionValue, ...);
%
% ## Input
% * __undistorted__ Object points. A Nx2, 1xNx2, or Nx1x2 array, where N is
%   the number of points in the view.
% * __K__ Camera matrix 3x3, `K = [fx 0 cx; 0 fy cy; 0 0 1]`.
% * __D__ Input vector of distortion coefficients `[k1,k2,k3,k4]`.
%
% ## Output
% * __distorted__ Output array of image points.
%
% ## Options
% * __Alpha__ The skew coefficient. default 0
%
% Note that the function assumes the camera matrix of the undistorted points
% to be identity. This means if you want to transform back points undistorted
% with cv.fisheyeUndistortPoints you have to multiply them with `inv(P)`.
%
% See also: cv.fisheyeUndistortPoints
%

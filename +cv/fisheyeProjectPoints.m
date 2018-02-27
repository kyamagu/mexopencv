%FISHEYEPROJECTPOINTS  Projects points using fisheye model
%
%     imagePoints = cv.fisheyeProjectPoints(objectPoints, rvec, tvec, K)
%     [imagePoints, jacobian] = cv.fisheyeProjectPoints(...)
%     [...] = cv.fisheyeProjectPoints(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ Array of object points, Nx3/Nx1x3/1xNx3 array or cell
%   array of 3-element vectors `{[x,y,z],...}`, where `N` is the number of
%   points in the view.
% * __rvec__ Rotation vector or matrix (3x1/1x3 or 3x3). See cv.Rodrigues for
%   details.
% * __tvec__ Translation vector (3x1/1x3).
% * __K__ Camera matrix 3x3, `K = [fx 0 cx; 0 fy cy; 0 0 1]`.
%
% ## Output
% * __imagePoints__ Output array of image points, Nx2/Nx1x2/1xNx2 array or
%   cell array of 2-element vectors `{[x,y], ...}`.
% * __jacobian__ Optional output `(2N)x(2+2+4+3+3+1)` jacobian matrix of
%   derivatives of image points with respect to components of the
%   focal lengths (2), coordinates of the principal point (2), distortion
%   coefficients (4), rotation vector (3), translation vector (3), and the
%   skew (1).
%
% ## Options
% * __DistCoeffs__ Input vector of distortion coefficients `[k1,k2,k3,k4]`. If
%   the vector is empty, the zero distortion coefficients are assumed.
%   default empty
% * __Alpha__ The skew coefficient. default 0
%
% The function computes projections of 3D points to the image plane given
% intrinsic and extrinsic camera parameters. Optionally, the function computes
% Jacobians - matrices of partial derivatives of image points coordinates
% (as functions of all the input parameters) with respect to the particular
% parameters, intrinsic and/or extrinsic.
%
% See also: cv.projectPoints
%

%PROJECTPOINTS  Projects 3D points to an image plane
%
%    imagePoints = cv.projectPoints(objectPoints, rvec, tvec, cameraMatrix)
%    [imagePoints, jacobian] = cv.projectPoints(...)
%    [...] = cv.projectPoints(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ Array of object points, Nx3/Nx1x3/1xNx3 array or cell
%       array of 3-element vectors `{[x,y,z],...}`, where `N` is the number of
%       points in the view.
% * __rvec__ Rotation vector or matrix (3x1/1x3 or 3x3). See cv.Rodrigues for
%       details.
% * __tvec__ Translation vector (3x1/1x3).
% * __cameraMatrix__ Camera matrix 3x3, `A = [fx 0 cx; 0 fy cy; 0 0 1]`.
%
% ## Output
% * __imagePoints__ Output array of image points, Nx2/Nx1x2/1xNx2 array or
%       cell array of 2-element vectors `{[x,y], ...}`.
% * __jacobian__ Optional output `(2N)x(3+3+2+2+numel(DistCoeffs))` jacobian
%       matrix of derivatives of image points with respect to components of
%       the rotation vector (3), translation vector (3), focal lengths (2),
%       coordinates of the principal point (2), and the distortion
%       coefficients (`numel(DistCoeffs)`).
%
% ## Options
% * __DistCoeffs__ Input vector of distortion coefficients
%       `[k1,k2,p1,p2,k3,k4,k5,k6,s1,s2,s3,s4]` of 4, 5, 8, or 12 elements.
%       If the vector is empty, the zero distortion coefficients are assumed.
%       default empty
% * __AspectRatio__ Optional "fixed aspect ratio" parameter. If the
%       parameter is not 0, the function assumes that the aspect ratio
%       (`fx/fy`) is fixed and correspondingly adjusts the jacobian matrix.
%       default 0.
%
% The function computes projections of 3D points to the image plane given
% intrinsic and extrinsic camera parameters. Optionally, the function
% computes Jacobians - matrices of partial derivatives of image points
% coordinates (as functions of all the input parameters) with respect to
% the particular parameters, intrinsic and/or extrinsic. The Jacobians are
% used during the global optimization in cv.calibrateCamera, cv.solvePnP,
% and cv.stereoCalibrate. The function itself can also be used to compute a
% re-projection error given the current intrinsic and extrinsic parameters.
%
% ## Note
% By setting `rvec=tvec=[0,0,0]` or by setting `cameraMatrix` to a 3x3
% identity matrix, or by passing zero distortion coefficients, you can get
% various useful partial cases of the function. This means that you can
% compute the distorted coordinates for a sparse set of points or apply a
% perspective transformation (and also compute the derivatives) in the
% ideal zero-distortion setup.
%
% See also: cv.calibrateCamera, cv.solvePnP, cv.Rodrigues, cv.stereoCalibrate
%

%RODRIGUES  Converts a rotation matrix to a rotation vector or vice versa
%
%    dst = cv.Rodrigues(src)
%    [dst,jacobian] = cv.Rodrigues(src)
%
% ## Input
% * __src__ Input rotation vector (3x1 or 1x3) or rotation matrix (3x3).
%
% ## Output
% * __dst__ Output rotation matrix (3x3) or rotation vector (3x1 or 1x3),
%        respectively.
% * __jacobian__ Optional output Jacobian matrix, 3x9 or 9x3, which is a
%        matrix of partial derivatives of the output array components with
%        respect to the input array components.
%
% The function transforms a rotation matrix in the following way:
%
%    theta <- norm(r)
%    r <- r/theta
%    R = cos(theta) * I + (1 - cos(theta)) * r * r^T + sin(theta) * A
%    A = [0, -rz, ry; rz, 0, -rx; -ry, rx, 0]
%
% Inverse transformation can be also done easily, since
% 
%    sin(theta) * A = (R - R^T) / 2
%
% A rotation vector is a convenient and most compact representation of a
% rotation matrix (since any rotation matrix has just 3 degrees of
% freedom). The representation is used in the global 3D geometry
% optimization procedures like cv.calibrateCamera, cv.stereoCalibrate, or
% cv.solvePnP.
%
% See also cv.calibrateCamera cv.stereoCalibrate cv.solvePnP
%

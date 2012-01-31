%RODRIGUES  Converts a rotation matrix to a rotation vector or vice versa
%
%   dst = cv.Rodrigues(src)
%   [dst,jacobian] = cv.Rodrigues(src)
%
% Input:
%    src: Input rotation vector (3x1 or 1x3) or rotation matrix (3x3).
% Output:
%    dst: Output rotation matrix (3x3) or rotation vector (3x1 or 1x3),
%        respectively.
%    jacobian: Optional output Jacobian matrix, 3x9 or 9x3, which is a
%        matrix of partial derivatives of the output array components with
%        respect to the input array components.
%
%    theta <- norm(r)
%    r <- r/theta
%    R = cos(theta) * I + (1 - cos(theta))*r*r^T + sin(theta) * A
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
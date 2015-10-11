%RQDECOMP3X3  Computes an RQ decomposition of 3x3 matrices
%
%    [R,Q] = cv.RQDecomp3x3(M)
%    [R,Q,S] = cv.RQDecomp3x3(M)
%
% ## Input
% * __M__ 3x3 input matrix.
%
% ## Output
% * __R__ 3x3 upper-triangular matrix.
% * __Q__ 3x3 orthogonal matrix.
% * __S__ Optional output struct with the following fields:
%       * __Qx__ 3x3 rotation matrix around x-axis.
%       * __Qy__ 3x3 rotation matrix around y-axis.
%       * __Qz__ 3x3 rotation matrix around z-axis.
%       * __eulerAngles__ 3-element vector containing three Euler angles of
%             rotation in degrees.
%
% The function computes a RQ decomposition using the given rotations. This
% function is used in cv.decomposeProjectionMatrix to decompose the left
% 3x3 submatrix of a projection matrix into a camera and a rotation matrix.
%
% It optionally returns three rotation matrices, one for each axis, and the
% three Euler angles (as the return value) that could be used in OpenGL. Note,
% there is always more than one sequence of rotations about the three
% principle axes that results in the same orientation of an object, eg. see
% [Slabaugh]. Returned tree rotation matrices and corresponding three Euler
% angules are only one of the possible solutions.
%
% ## References
% [Slabaugh]:
% > Gregory G Slabaugh. "Computing euler angles from a rotation matrix".
% > Retrieved on August, 6:2000, 1999.
%
% See also: cv.decomposeProjectionMatrix, qr
%

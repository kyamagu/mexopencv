%RQDECOMP3X3  Computes an RQ decomposition of 3x3 matrices
%
%   [R,Q] = cv.RQDecomp3x3(M)
%   [R,Q,Qx,Qy,Qz] = cv.RQDecomp3x3(M)
%
% Input:
%    M: 3x3 input matrix.
% Output:
%    R: 3x3 upper-triangular matrix.
%    Q: 3x3 orthogonal matrix.
%    Qx: 3x3 rotation matrix around x-axis.
%    Qy: 3x3 rotation matrix around y-axis
%    Qz: 3x3 rotation matrix around z-axis
%
% The function computes a RQ decomposition using the given rotations. This
% function is used in cv.decomposeProjectionMatrix to decompose the left
% 3x3 submatrix of a projection matrix into a camera and a rotation matrix.
% 
% It optionally returns three rotation matrices, one for each axis, and the
% three Euler angles (as the return value) that could be used in OpenGL.
%
% See also cv.decomposeProjectionMatrix
%
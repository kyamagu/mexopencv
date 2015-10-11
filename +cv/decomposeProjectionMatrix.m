%DECOMPOSEPROJECTIONMATRIX  Decomposes a projection matrix into a rotation matrix and a camera matrix
%
%    [cameraMatrix,rotMatrix,transVect] = cv.decomposeProjectionMatrix(projMatrix)
%    [cameraMatrix,rotMatrix,transVect,S] = cv.decomposeProjectionMatrix(projMatrix)
%
% ## Input
% * __projMatrix__ 3x4 input projection matrix P.
%
% ## Output
% * __cameraMatrix__ 3x3 camera matrix K.
% * __rotMatrix__ 3x3 external rotation matrix R.
% * __transVect__ 4x1 translation vector T.
% * __S__ Optional output struct with the following fields:
%       * __rotMatrX__ 3x3 rotation matrix around x-axis.
%       * __rotMatrY__ 3x3 rotation matrix around y-axis.
%       * __rotMatrZ__ 3x3 rotation matrix around z-axis.
%       * __eulerAngles__ 3-element vector containing three Euler angles of
%             rotation in degrees.
%
% The function computes a decomposition of a projection matrix into a
% calibration and a rotation matrix and the position of a camera.
%
% It optionally returns three rotation matrices, one for each axis, and
% three Euler angles that could be used in OpenGL. Note, there is always more
% than one sequence of rotations about the three principle axes that results
% in the same orientation of an object, eg. see [Slabaugh]. Returned three
% rotation matrices and corresponding three Euler angules are only one of the
% possible solutions.
%
% The function is based on cv.RQDecomp3x3
%
% ## References
% [Slabaugh]:
% > Gregory G Slabaugh. "Computing euler angles from a rotation matrix".
% > Retrieved on August, 6:2000, 1999.
%
% See also: cv.RQDecomp3x3
%

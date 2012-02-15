%DECOMPOSEPROJECTIONMATRIX  Decomposes a projection matrix into a rotation matrix and a camera matrix
%
%    S = cv.decomposeProjectionMatrix(projMatrix)
%
% ## Input
% * __projMatrix__ 3x4 input projection matrix P.
%
% ## Output
% * __S__ Struct with the following fields
% * __cameraMatrix__ 3x3 camera matrix K.
% * __rotMatrix__ 3x3 external rotation matrix R.
% * __transVect__ 4x1 translation vector T.
% * __rotMatrX__ 3x3 rotation matrix around x-axis.
% * __rotMatrY__ 3x3 rotation matrix around y-axis.
% * __rotMatrZ__ 3x3 rotation matrix around z-axis.
% * __eulerAngles__ three-element vector containing three Euler angles of
%            rotation.
%
% The function computes a decomposition of a projection matrix into a
% calibration and a rotation matrix and the position of a camera.
%
% It optionally returns three rotation matrices, one for each axis, and
% three Euler angles that could be used in OpenGL.
%
% The function is based on cv.RQDecomp3x3
%
% See also cv.RQDecomp3x3
%

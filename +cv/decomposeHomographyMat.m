%DECOMPOSEESSENTIALMAT  Decompose a homography matrix to rotation(s), translation(s) and plane normal(s)
%
%    [motions, nsols] = cv.decomposeHomographyMat(H, K)
%
% ## Input
% * __H__ The input homography matrix between two images, 3x3.
% * __K__ The input intrinsic camera calibration matrix, 3x3.
%
% ## Output
% * __motions__ Decomposed `H`. A scalar struct with the following fields:
%       * __R__ Array of rotation matrices. Cell array of 3x3 rotations.
%       * __t__ Array of translation matrices. Cell array of 3x1 translations.
%       * __n__ Array of plane normal matrices. Cell array of 3x1 normals.
% * __nsols__ number of solutions.
%
% This function extracts relative camera motion between two views observing a
% planar object from the homography `H` induced by the plane. The intrinsic
% camera matrix `K` must also be provided. The function may return up to four
% mathematical solution sets. At least two of the solutions may further be
% invalidated if point correspondences are available by applying positive
% depth constraint (all points must be in front of the camera). The
% decomposition method is described in detail in [Malis].
%
% ## References
% [Malis]:
% > Ezio Malis, Manuel Vargas, and others. "Deeper understanding of the
% > homography decomposition for vision-based control". 2007.
%
% See also: cv.findHomography, cv.decomposeEssentialMat
%

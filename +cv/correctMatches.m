%CORRECTMATCHES  Refines coordinates of corresponding points
%
%    [newPoints1, newPoints2] = cv.correctMatches(F, points1, points2)
%
% ## Input
% * __F__ 3x3 fundamental matrix.
% * __points1__ first set of 2D points. A numeric Nx2/Nx1x2/1xNx2 array or a
%       cell array of 2-element vectors `{[x,y], ...}` (floating-point
%       precision).
% * __points2__ second set of 2D points. Same size and type as `points1`.
%
% ## Output
% * __newPoints1__ The optimized `points1`. Similar in shape to `points1`
%       (either Nx2/1xNx2 numeric array or cell array of 2D points).
% * __newPoints2__ The optimized `points2`.
%
% The function implements the Optimal Triangulation Method (see [Hartley2004]
% for details). For each given point correspondence `points1[i] <-> points2[i]`,
% and a fundamental matrix `F`, it computes the corrected correspondences
% `newPoints1[i] <-> newPoints2[i]` that minimize the geometric error:
%
%    d(points1[i], newPoints1[i])^2 + d(points2[i], newPoints2[i])^2
%
% (where `d(a,b)` is the geometric distance between points `a` and `b`)
% subject to the epipolar constraint
%
%    newPoints2' * F * newPoints1 = 0
%
% ## References
% [Hartley2004]:
% > R.I. Hartley and A. Zisserman. "Multiple View Geometry in Computer Vision"
% > Cambridge University Press, 2004.
%
% See also: cv.findFundamentalMat
%

%MINENCLOSINGCIRCLE  Finds a circle of the minimum area enclosing a 2D point set
%
%    [center,radius] = cv.minEnclosingCircle(points)
%
% ## Input
% * __points__ Input vector of 2D points, stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%
% ## Output
% * __center__ Output center of circle `[x,y]`.
% * __radius__ Output radius of circle `r`.
%
% The function finds the minimal enclosing circle of a 2D point set using an
% iterative algorithm.
%
% See also: cv.minEnclosingTriangle
%

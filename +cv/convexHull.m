%CONVEXHULL  Finds the convex hull of a point set
%
%    hull = cv.convexHull(points)
%    hull = cv.convexHull(points, 'OptionName', optionValue, ...)
%
% ## Input
% * __points__ Input 2D point set, stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%
% ## Output
% * __hull__ Output convex hull. It is either an integer vector of indices or
%       vector of points. In the first case, the hull elements are 0-based
%       indices of the convex hull points in the original array (since the set
%       of convex hull points is a subset of the original point set). In the
%       second case, hull elements are the convex hull points themselves.
%       In case output is the hull points, it has the same type as the input.
%
% ## Options
% * __ReturnPoints__ Operation flag. In case of a matrix, when the flag is
%       true, the function returns convex hull points (Mx2 matrix). Otherwise,
%       it returns indices of the convex hull points (vector of length M).
%       In case the input is a cell-array, when the flag is true, the function
%       return convex hull points (as a cell-array of points). Otherwise it
%       returns indices of points (vector of length M). default true
% * __Clockwise__ Orientation flag. If it is true, the output convex hull is
%       oriented clockwise. Otherwise, it is oriented counter-clockwise. The
%       usual screen coordinate system is assumed so that the origin is at the
%       top-left corner, x axis is oriented to the right, and y axis is
%       oriented downwards. default false
%
% The functions find the convex hull of a 2D point set using the Sklansky's
% algorithm [Sklansky82] that has `O(N logN)` complexity in the current
% implementation.
%
% ## References
% [Sklansky82]:
% > Jack Sklansky. "Finding the convex hull of a simple polygon".
% > Pattern Recognition Letters, 1(2):79-83, 1982.
%
% See also: convhull, convhulln
%

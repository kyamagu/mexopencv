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
% * __hull__ Output convex hull. The type is the same to the input.
%
% ## Options
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

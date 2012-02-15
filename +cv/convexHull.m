%CONVEXHULL  Finds the convex hull of a point set
%
%    hull = cv.convexHull(points)
%    hull = cv.convexHull(points, 'OptionName', optionValue, ...)
%
% ## Input
% * __points__ Input vector of a 2D point stored in an 1-by-N-by-2 numeric array
%         or a cell array of 2-element vectors.
%
% ## Output
% * __hull__ Output convex hull. The type is the same to the input.
%
% ## Options
% * __Clockwise__ Orientation flag. If it is true, the output convex hull is
%         oriented clockwise. Otherwise, it is oriented counter-clockwise. The
%         usual screen coordinate system is assumed so that the origin is at the
%         top-left corner, x axis is oriented to the right, and y axis is
%         oriented downwards.
%
% The functions find the convex hull of a 2D point set using the Sklansky's
% algorithm [Sklansky82] that has O(N logN) complexity in the current
% implementation. See the OpenCV sample convexhull.cpp that demonstrates the
% usage of different function variants.
%

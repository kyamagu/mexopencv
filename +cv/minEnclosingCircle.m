%MINENCLOSINGCIRCLE  Finds a circle of the minimum area enclosing a 2D point set
%
%    [center,radius] = cv.minEnclosingCircle(points)
%
% ## Input
% * __points__ Input 2D point set, stored in a cell array of 2-element vectors or
%         1-by-N-by-2 numeric array.
%
% ## Output
% * __center__ Output center of circle.
% * __radius__ Output radius of circle.
%
% The function finds the minimal enclosing circle of a 2D point set using an
% iterative algorithm.
%

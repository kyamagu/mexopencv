%MINENCLOSINGCIRCLE  Finds a circle of the minimum area enclosing a 2D point set
%
%   [center,radius] = cv.minEnclosingCircle(points)
%
% Input:
%     points: Input 2D point set, stored in a cell array of 2-element vectors or
%         1-by-N-by-2 numeric array.
% Output:
%     center: Output center of circle.
%     radius: Output radius of circle.
%
% The function finds the minimal enclosing circle of a 2D point set using an
% iterative algorithm.
%
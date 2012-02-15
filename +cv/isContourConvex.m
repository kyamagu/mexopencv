%ISCONTOURCONVEX  Tests a contour convexity
%
%    status = cv.isContourConvex(contour)
%
% ## Input
% * __contour__ Input 2D point set, stored in a cell array of 2-element vectors or
%         1-by-N-by-2 numeric array.
%
% ## Output
% * __status__ Output logical value.
%
% The function tests whether the input contour is convex or not. The contour
% must be simple, that is, without self-intersections. Otherwise, the function
% output is undefined.
%

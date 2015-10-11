%ISCONTOURCONVEX  Tests a contour convexity
%
%    status = cv.isContourConvex(contour)
%
% ## Input
% * __contour__ Input vector of 2D points, stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%
% ## Output
% * __status__ Output logical value.
%
% The function tests whether the input contour is convex or not. The contour
% must be simple, that is, without self-intersections. Otherwise, the function
% output is undefined.
%

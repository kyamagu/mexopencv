%MINENCLOSINGTRIANGLE  Finds a triangle of minimum area enclosing a 2D point set and returns its area.
%
%    [triangle,area] = cv.minEnclosingTriangle(points)
%
% ## Input
% * __points__ Input vector of 2D points with depth `int32` or `single`,
%       stored in numeric array (Nx2/Nx1x2/1xNx2) or cell array of 2-element
%       vectors (`{[x,y], ...}`).
%
% ## Output
% * __triangle__ Output vector of three 2D points defining the vertices of the
%       triangle.
% * __area__ triangle area
%
% The function finds a triangle of minimum area enclosing the given set of 2D
% points and returns its area.
%
% The implementation of the algorithm is based on O'Rourke's [ORourke86] and
% Klee and Laskowski's [KleeLaskowski85] papers. O'Rourke provides a
% `theta(n)` algorithm for finding the minimal enclosing triangle of a 2D
% convex polygon with `n` vertices. Since the cv.minEnclosingTriangle function
% takes a 2D point set as input an additional preprocessing step of computing
% the convex hull of the 2D point set is required. The complexity of the
% cv.convexHull function is `O(nlog(n))` which is higher than `theta(n)`.
% Thus the overall complexity of the function is `O(nlog(n))`.
%
% ## References
% [ORourke86]:
% > Joseph O'Rourke, Alok Aggarwal, Sanjeev Maddila, and Michael Baldwin.
% > "An optimal algorithm for finding minimal enclosing triangles".
% > Journal of Algorithms, 7(2):258-269, 1986.
%
% [KleeLaskowski85]:
% > Victor Klee and Michael C Laskowski.
% > "Finding the smallest triangles containing a given convex polygon".
% > Journal of Algorithms, 6(3):359-375, 1985.
%
% See also: cv.minEnclosingCircle, cv.convexHull
%

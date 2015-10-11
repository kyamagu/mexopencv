%INTERSECTCONVEXCONVEX  Finds intersection of two convex polygons
%
%    [p12,area] = cv.intersectConvexConvex(p1, p2)
%    [...] = cv.intersectConvexConvex(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __p1__ first polygon, stored in numeric array (Nx2/Nx1x2/1xNx2) or
%       cell array of 2-element vectors (`{[x,y], ...}`).
% * __p2__ second polygon, stored in numeric array (Nx2/Nx1x2/1xNx2) or
%       cell array of 2-element vectors (`{[x,y], ...}`).
%
% ## Output
% * __p12__ intersection polygon points, a cell array of 2-element vectors
%       `{[x,y], ...}`
% * __a__ area
%
% ## Options
% * __HandleNested__ default true
%

%FILLPOLY  Fills the area bounded by one or more polygons
%
%    img = cv.fillConvexPoly(img, pts)
%    [...] = cv.fillConvexPoly(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image.
% * __pts__ Polygon vertices in cell array of cell array of 2-element
%        vectors.
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __Color__ 3-element floating point vector specifying polygon color.
% * __LineType__ Type of the ellipse boundary. One of 8,4,'AA'
%        (Anti-aliased line). default 8.
% * __Shift__ Number of fractional bits in the point coordinates. default 0
%
% The function fillPoly fills an area bounded by several polygonal
% contours. The function can fill complex areas, for example, areas with
% holes, contours with self-intersections (some of thier parts), and so
% forth.
%
% See also cv.line cv.fillConvexPoly
%

%FILLPOLY  Fills the area bounded by one or more polygons
%
%     img = cv.fillPoly(img, pts)
%     [...] = cv.fillPoly(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image.
% * __pts__ Array of polygons where each polygon is represented as an array
%   of points. A cell array of cell arrays of 2-element vectors, in the form:
%   `{{[x,y], [x,y], ...}, ...}`, or a cell array of Nx2 matrices.
%
% ## Output
% * __img__ Output image, same size and type as input `img`.
%
% ## Options
% * __Color__ 3-element floating-point vector specifying polygon color.
%   default zeros
% * __LineType__ Type of the polygon boundaries. One of:
%   * __4__ 4-connected line
%   * __8__ 8-connected line (default)
%   * __AA__ anti-aliased line
% * __Shift__ Number of fractional bits in the vertex coordinates. default 0
% * __Offset__ Optional offset of all points of the contours. default `[0,0]`
%
% The function cv.fillPoly fills an area bounded by several polygonal
% contours. The function can fill complex areas, for example, areas with
% holes, contours with self-intersections (some of thier parts), and so forth.
%
% See also: cv.line, cv.fillConvexPoly, roipoly, poly2mask
%

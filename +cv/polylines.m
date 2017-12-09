%POLYLINES  Draws several polygonal curves
%
%     img = cv.polylines(img, pts)
%     [...] = cv.polylines(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image.
% * __pts__ Array of polygonal curves, where each polygon is represented as an
%   array of points. A cell array of cell arrays of 2-element vectors, in the
%   form `{{[x,y], [x,y], ...}, ...}`, or a cell array of Nx2 matries.
%
% ## Output
% * __img__ Output image, same size and type as input `img`.
%
% ## Options
% * __Closed__ Flag indicating whether the drawn polylines are closed or not.
%   If they are closed, the function draws a line from the last vertex of each
%   curve to its first vertex. default true.
% * __Color__ 3-element floating-point vector specifying polyline color.
%   default zeros
% * __Thickness__ Thickness of the polyline edges. default 1.
% * __LineType__ Type of the line segments. One of:
%   * __4__ 4-connected line
%   * __8__ 8-connected line (default)
%   * __AA__ anti-aliased line
% * __Shift__ Number of fractional bits in the vertex coordinates. default 0.
%
% The function cv.polylines draws one or more polygonal curves.
%
% See also: cv.circle, cv.line, cv.rectangle, cv.fillPoly, cv.fillConvexPoly
%

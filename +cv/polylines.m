%POLYLINES  Draws several polygonal curves
%
%   img = cv.polylines(img, pts)
%   [...] = cv.polylines(..., 'OptionName', optionValue, ...)
%
% Input:
%    img: Image.
%    pts: Array of polygonal curves. That is, cell array of cell array of
%        2-element vectors.
% Output:
%    img: Output image.
% Options:
%    'Closed': Flag indicating whether the drawn polylines are closed or
%        not. If they are closed, the function draws a line from the last
%        vertex of each curve to its first vertex. default true.
%    'Color': 3-element floating point vector specifying line color.
%    'Thickness': Line thickness. default 1.
%    'LineType': Type of the line boundary. One of 8,4,'AA' (Anti-aliased
%        line). default 8.
%    'Shift': Number of fractional bits in the vertex coordinates. default
%        0.
%
% The function polylines draws one or more polygonal curves.
%
% See also cv.circle cv.line cv.rectangle cv.fillPoly cv.fillConvexPoly
%
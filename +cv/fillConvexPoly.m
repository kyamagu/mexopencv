%FILLCONVEXPOLY  Fills a convex polygon
%
%   img = cv.fillConvexPoly(img, pts)
%   [...] = cv.fillConvexPoly(..., 'OptionName', optionValue, ...)
%
% Input:
%    img: Image.
%    pts: Polygon vertices in cell array of 2-element vectors.
% Output:
%    img: Output image.
% Options:
%    'Color': 3-element floating point vector specifying polygon color.
%    'LineType': Type of the ellipse boundary. One of 8,4,'AA'
%        (Anti-aliased line). default 8.
%    'Shift': Number of fractional bits in the point coordinates. default 0
%
% The function fillConvexPoly draws a filled convex polygon. This function
% is much faster than the function fillPoly . It can fill not only convex
% polygons but any monotonic polygon without self-intersections, that is,
% a polygon whose contour intersects every horizontal line (scan line)
% twice at the most (though, its top-most and/or the bottom edge could be
% horizontal).
%
% See also cv.line cv.fillPoly
%
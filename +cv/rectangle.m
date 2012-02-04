%RECTANGLE  Draws a simple, thick, or filled up-right rectangle
%
%   img = cv.rectangle(img, pt1, pt2)
%   img = cv.rectangle(img, rect)
%   [...] = cv.rectangle(..., 'OptionName', optionValue, ...)
%
% Input:
%    img: Image.
%    pt1: Vertex of the rectangle. [x1,y1].
%    pt2: Vertex of the recangle opposite to pt1. [x2,y2]
%    rect: Alternative specification of the drawn rectangle. [x,y,w,h]
% Output:
%    img: Output image.
% Options:
%    'Color': 3-element floating point vector specifying line color.
%    'Thickness': Thickness of lines that make up the rectangle. Negative
%       values, mean that the function has to draw a filled rectangle.
%       default 1.
%    'LineType': Type of the line boundary. One of 8,4,'AA' (Anti-aliased
%        line). default 8.
%    'Shift': Number of fractional bits in the point coordinates. default 0
%
% The function rectangle draws a rectangle outline or a filled rectangle
% whose two opposite corners are pt1 and pt2, or r.tl() and
% r.br()-Point(1,1).
%
% See also cv.circle cv.ellipse cv.line cv.polylines
%
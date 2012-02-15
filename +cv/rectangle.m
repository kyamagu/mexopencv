%RECTANGLE  Draws a simple, thick, or filled up-right rectangle
%
%    img = cv.rectangle(img, pt1, pt2)
%    img = cv.rectangle(img, rect)
%    [...] = cv.rectangle(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image.
% * __pt1__ Vertex of the rectangle. [x1,y1].
% * __pt2__ Vertex of the recangle opposite to pt1. [x2,y2]
% * __rect__ Alternative specification of the drawn rectangle. [x,y,w,h]
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __Color__ 3-element floating point vector specifying line color.
% * __Thickness__ Thickness of lines that make up the rectangle. Negative
%       values, mean that the function has to draw a filled rectangle.
%       default 1.
% * __LineType__ Type of the line boundary. One of 8,4,'AA' (Anti-aliased
%        line). default 8.
% * __Shift__ Number of fractional bits in the point coordinates. default 0
%
% The function rectangle draws a rectangle outline or a filled rectangle
% whose two opposite corners are pt1 and pt2, or r.tl() and
% r.br()-Point(1,1).
%
% See also cv.circle cv.ellipse cv.line cv.polylines
%

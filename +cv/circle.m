%CIRCLE  Draws a circle
%
%   img = cv.cicle(img, center, radius)
%   [...] = cv.cicle(..., 'OptionName', optionValue, ...)
%
% Input:
%    img: Image where the circle is drawn.
%    center: Center of the circle.
%    radius: Radius of the circle.
% Output:
%    img: Output image.
% Options:
%    'Color': 3-element floating point vector specifying circle color.
%    'Thickness': Thickness of the circle outline, if positive. Negative
%        thickness means that a filled circle is to be drawn. default 1.
%    'LineType': Type of the circle boundary. One of 8,4,'AA' (Anti-aliased
%        line). default 8.
%    'Shift': Number of fractional bits in the coordinates of the center
%        and in the radius value. default 0.
%
% The function circle draws a simple or filled circle with a given center
% and radius.
%
% See also cv.line cv.ellipse cv.rectangle
%
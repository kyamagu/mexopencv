%CIRCLE  Draws a circle
%
%    img = cv.circle(img, center, radius)
%    [...] = cv.circle(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image where the circle is drawn.
% * __center__ Center of the circle.
% * __radius__ Radius of the circle.
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __Color__ 3-element floating point vector specifying circle color.
% * __Thickness__ Thickness of the circle outline, if positive. Negative
%        thickness means that a filled circle is to be drawn. default 1.
% * __LineType__ Type of the circle boundary. One of 8,4,'AA' (Anti-aliased
%        line). default 8.
% * __Shift__ Number of fractional bits in the coordinates of the center
%        and in the radius value. default 0.
%
% The function circle draws a simple or filled circle with a given center
% and radius.
%
% See also cv.line cv.ellipse cv.rectangle
%

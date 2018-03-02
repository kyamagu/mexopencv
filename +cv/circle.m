%CIRCLE  Draws a circle
%
%     img = cv.circle(img, center, radius)
%     [...] = cv.circle(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image where the circle is drawn.
% * __center__ Center of the circle `[x,y]`.
% * __radius__ Radius of the circle.
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __Color__ 3-element floating-point vector specifying circle color.
%   default is a black color
% * __Thickness__ Thickness of the circle outline, if positive. Negative
%   values (like -1 or the string 'Filled') mean that a filled circle is to be
%   drawn . default 1.
% * __LineType__ Type of the circle boundary. One of:
%   * __4__ 4-connected line
%   * __8__ 8-connected line (default)
%   * __AA__ anti-aliased line
% * __Shift__ Number of fractional bits in the coordinates of the center and
%   in the radius value. default 0.
%
% The function cv.circle draws a simple or filled circle with a given center
% and radius.
%
% See also: cv.line, cv.ellipse, cv.rectangle, viscircles
%

%ELLIPSE  Draws a simple or thick elliptic arc or fills an ellipse sector
%
%    img = cv.ellipse(img, center, axes)
%    img = cv.ellipse(img, box)
%    [...] = cv.ellipse(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image where the ellipse is drawn.
% * __center__ Center of the ellipse `[x,y]`.
% * __axes__ Half of the size of the ellipse main axes `[a,b]`.
% * __box__ Alternative ellipse representation via a rotated rectangle box.
%       This means that the function draws an ellipse inscribed in the rotated
%       rectangle. A scalar structure with the following fields:
%       * __center__ The rectangle mass center `[x,y]`.
%       * __size__ Width and height of the rectangle `[w,h]`.
%       * __angle__ The rotation angle in a clockwise direction. When the
%         angle is 0, 90, 180, 270 etc., the rectangle becomes an up-right
%         rectangle.
%
% ## Output
% * __img__ Output image, same size and type as input `img`.
%
% ## Options
% * __Angle__ Ellipse rotation angle in degrees. default 0.
% * __StartAngle__ Starting angle of the elliptic arc in degrees. default 0
% * __EndAngle__ Ending angle of the elliptic arc in degrees. default 360
% * __Color__ 3-element floating point vector specifying ellipse color.
% * __Thickness__ Thickness of the ellipse arc outline, if positive.
%       Otherwise, this indicates that a filled ellipse sector is to be drawn
%       (-1 or the string 'Filled'). default 1.
% * __LineType__ Type of the ellipse boundary. One of 8,4,'AA' (Anti-aliased
%       line). default 8.
% * __Shift__ Number of fractional bits in the coordinates of the center and
%       values of axes. default 0.
%
% The first variant of the cv.ellipse function draw an ellipse outline, a
% filled ellipse, an elliptic arc, or a filled ellipse sector. A piecewise-
% linear curve is used to approximate the elliptic arc boundary. If you need
% more control of the ellipse rendering, you can retrieve the curve using
% cv.ellipse2Poly and then render it with cv.polylines or fill it with
% cv.fillPoly. If you use the first variant of the function and want to draw
% the whole ellipse, not an arc, pass `StartAngle=0` and `EndAngle=360`.
%
% The second variant of the function (with rotated rectange as input) does not
% support the `Angle`, `StartAngle`, `EndAngle`, and `Shift` parameters
% (always draw a whole ellipse, not an arc).
%
% See also: cv.line, cv.circle, cv.rectangle
%

%ELLIPSE  Draws a simple or thick elliptic arc or fills an ellipse sector
%
%    img = cv.ellipse(img, center, axes)
%    [...] = cv.ellipse(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image where the ellipse is drawn.
% * __center__ Center of the ellipse [x,y].
% * __axes__ Length of the ellipse axes [a,b].
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __Angle__ Ellipse rotation angle in degrees. default 0.
% * __StartAngle__ Starting angle of the elliptic arc in degrees. default 0
% * __EndAngle__ Ending angle of the elliptic arc in degrees. default 360
% * __Color__ 3-element floating point vector specifying ellipse color.
% * __Thickness__ Thickness of the ellipse arc outline, if positive.
%         Otherwise, this indicates that a filled ellipse sector is to be
%         drawn. default 1.
% * __LineType__ Type of the ellipse boundary. One of 8,4,'AA'
%        (Anti-aliased line). default 8.
% * __Shift__ Number of fractional bits in the coordinates of the center
%        and values of axes. default 0.
%
% The functions ellipse with less parameters draw an ellipse outline, a
% filled ellipse, an elliptic arc, or a filled ellipse sector. A piecewise-
% linear curve is used to approximate the elliptic arc boundary. If you
% need more control of the ellipse rendering, you can retrieve the curve
% using cv.ellipse2Poly and then render it with polylines or fill it with
% cv.fillPoly. If you use the first variant of the function and want to
% draw the whole ellipse, not an arc, pass startAngle=0 and endAngle=360.
%
% See also cv.line cv.circle cv.rectangle
%

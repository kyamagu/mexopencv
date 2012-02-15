%ELLIPSE2POLY  Approximates an elliptic arc with a polyline
%
%    pts = cv.ellipse2Poly(center, axes)
%    [...] = cv.ellipse2Poly(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image where the ellipse is drawn.
% * __center__ Center of the ellipse [x,y].
% * __axes__ Length of the ellipse axes [a,b].
%
% ## Output
% * __pts__ Output polyline points.
%
% ## Options
% * __Angle__ Rotation angle of the ellipse in degrees. default 0.
% * __StartAngle__ Starting angle of the elliptic arc in degrees. default 0
% * __EndAngle__ Ending angle of the elliptic arc in degrees. default 360
% * __Delta__ Angle between the subsequent polyline vertices. It defines
%        the approximation accuracy. default 5.
%
% The function ellipse2Poly computes the vertices of a polyline that
% approximates the specified elliptic arc. It is used by cv.ellipse.
%
% See also cv.ellipse
%

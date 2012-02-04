%ELLIPSE2POLY  Approximates an elliptic arc with a polyline
%
%   pts = cv.ellipse2Poly(center, axes)
%   [...] = cv.ellipse2Poly(..., 'OptionName', optionValue, ...)
%
% Input:
%    img: Image where the ellipse is drawn.
%    center: Center of the ellipse [x,y].
%    axes: Length of the ellipse axes [a,b].
% Output:
%    pts: Output polyline points.
% Options:
%    'Angle': Rotation angle of the ellipse in degrees. default 0.
%    'StartAngle': Starting angle of the elliptic arc in degrees. default 0
%    'EndAngle': Ending angle of the elliptic arc in degrees. default 360
%    'Delta': Angle between the subsequent polyline vertices. It defines
%        the approximation accuracy. default 5.
%
% The function ellipse2Poly computes the vertices of a polyline that
% approximates the specified elliptic arc. It is used by cv.ellipse.
%
% See also cv.ellipse
%
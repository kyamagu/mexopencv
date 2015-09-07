%ELLIPSE2POLY  Approximates an elliptic arc with a polyline
%
%    pts = cv.ellipse2Poly(center, axes)
%    [...] = cv.ellipse2Poly(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __center__ Center of the arc `[x,y]`.
% * __axes__ Half of the size of the ellipse main axes `[a,b]`. See cv.ellipse
%       for details.
%
% ## Output
% * __pts__ Output vector of polyline vertices. A cell-array of 2-element
%       vector `{[x,y], ...}`.
%
% ## Options
% * __Angle__ Rotation angle of the ellipse in degrees. See cv.ellipse for
%       details. default 0.
% * __StartAngle__ Starting angle of the elliptic arc in degrees. default 0
% * __EndAngle__ Ending angle of the elliptic arc in degrees. default 360
% * __Delta__ Angle between the subsequent polyline vertices. It defines the
%       approximation accuracy. default 5.
%
% The function cv.ellipse2Poly computes the vertices of a polyline that
% approximates the specified elliptic arc. It is used by cv.ellipse.
%
% See also: cv.ellipse
%

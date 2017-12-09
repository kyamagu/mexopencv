%CARTTOPOLAR  Calculates the magnitude and angle of 2D vectors
%
%     [mag, ang] = cv.cartToPolar(x, y)
%     [...] = cv.cartToPolar(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __x__ array of x-coordinates; this must be a single-precision or
%   double-precision floating-point array.
% * __y__ array of y-coordinates, that must have the same size and type as `x`.
%
% ## Output
% * __mag__ output array of magnitudes of the same size and type as `x`.
% * __ang__ output array of angles that has the same size and type as `x`; the
%   angles are measured in radians (from 0 to 2*pi) or in degrees (0 to 360
%   degrees).
%
% ## Options
% * __Degrees__ a flag, indicating whether the angles are measured in radians
%   (which is by default), or in degrees. default false
%
% The function cv.cartToPolar calculates either the magnitude, angle, or both
% for every 2D vector `(x(I),y(I))`:
%
%     magnitude(I) = sqrt(x(I)^2 + y(I)^2)
%     angle(I) = atan2(y(I), x(I)) [* (180/pi)]
%
% The angles are calculated with accuracy about 0.3 degrees. For the point
% `(0,0)`, the angle is set to 0.
%
% See also: cv.polarToCart, cv.magnitude, cv.phase, cart2pol
%

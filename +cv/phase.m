%PHASE  Calculates the rotation angle of 2D vectors
%
%     ang = cv.phase(x, y)
%     ang = cv.phase(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __x__ floating-point array of x-coordinates of 2D vectors.
% * __y__ floating-point array of y-coordinates of 2D vectors. It must have
%   the same size and type as `x`.
%
% ## Output
% * __ang__ output array of vector angles; it has the same size and type as
%   `x`.
%
% ## Options
% * __Degrees__ when true, the function calculates the angle in degrees,
%   otherwise, they are measured in radians. default false
%
% The function cv.phase calculates the rotation angle of each 2D vector that
% is formed from the corresponding elements of `x` and `y`:
%
%     angle(I) = atan2(y(I), x(I))
%
% The angle estimation accuracy is about 0.3 degrees. When `x(I)=y(I)=0`, the
% corresponding `angle(I)` is set to 0.
%
% See also: cv.magnitude, cv.cartToPolar, cv.polarToCart, angle, atan2, atan,
%  atan2d, atand, unwrap
%

%MAGNITUDE  Calculates the magnitude of 2D vectors
%
%     mag = cv.magnitude(x, y)
%
% ## Input
% * __x__ floating-point array of x-coordinates of the vectors.
% * __y__ floating-point array of y-coordinates of the vectors. It must have
%   the same size as `x`.
%
% ## Output
% * __mag__ output array of the same size and type as `x`.
%
% The function cv.magnitude calculates the magnitude of 2D vectors formed from
% the corresponding elements of `x` and `y` arrays:
%
%     dst(I) = sqrt(x(I)^2 + y(I)^2)
%
% See also: cv.phase, cv.cartToPolar, cv.polarToCart, abs, hypot, norm, sqrt
%

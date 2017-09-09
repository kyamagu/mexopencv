%POLARTOCART  Calculates x and y coordinates of 2D vectors from their magnitude and angle
%
%     [x, y] = cv.polarToCart(mag, ang)
%     [...] = cv.polarToCart(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __mag__ floating-point array of magnitudes of 2D vectors; it must have the
%   same size and type as `ang`.
% * __ang__ floating-point array of angles of 2D vectors.
%
% ## Output
% * __x__ output array of x-coordinates of 2D vectors; it has the same size
%   and type as `ang`.
% * __y__ output array of y-coordinates of 2D vectors; it has the same size
%   and type as `ang`.
%
% ## Options
% * __Degrees__ when true, the input angles are measured in degrees,
%   otherwise, they are measured in radians. default false
%
% The function cv.polarToCart calculates the Cartesian coordinates of each 2D
% vector represented by the corresponding elements of magnitude and angle:
%
%     x(I) = magnitude(I) * cos(angle(I))
%     y(I) = magnitude(I) * sin(angle(I))
%
% The relative accuracy of the estimated coordinates is about 1e-6.
%
% See also: cv.cartToPolar, cv.magnitude, cv.phase, pol2cart
%

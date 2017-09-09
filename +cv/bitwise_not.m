%BITWISE_NOT  Inverts every bit of an array
%
%     dst = cv.bitwise_not(src)
%     dst = cv.bitwise_not(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input array.
%
% ## Output
% * __dst__ output array that has the same size and type as the input array.
%
% ## Options
% * __Mask__ optional operation mask, 8-bit single channel array, that
%   specifies elements of the output array to be changed. Not set by default.
% * __Dest__ Used to initialize the output `dst` when a mask is used. Not set
%   by default.
%
% The function calculates per-element bit-wise inversion of the input array.
%
%     dst(I) = NOT src(I)
%
% In case of a floating-point input array, its machine-specific bit
% representation (usually IEEE754-compliant) is used for the operation. In
% case of multi-channel arrays, each channel is processed independently.
%
% See also: cv.bitwise_and, cv.bitwise_or, cv.bitwise_xor, bitcmp
%

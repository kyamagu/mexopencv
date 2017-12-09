%BITWISE_AND  Calculates the per-element bit-wise conjunction of two arrays or an array and a scalar
%
%     dst = cv.bitwise_and(src1, src2)
%     dst = cv.bitwise_and(src1, src2, 'OptionName', optionValue, ...)
%
% ## Input
% * __src1__ first input array or a scalar.
% * __src2__ second input array or a scalar. In case both are array, they must
%   have the same size and type.
%
% ## Output
% * __dst__ output array that has the same size and type as the input arrays.
%
% ## Options
% * __Mask__ optional operation mask, 8-bit single channel array, that
%   specifies elements of the output array to be changed. Not set by default.
% * __Dest__ Used to initialize the output `dst` when a mask is used. Not set
%   by default.
%
% Computes bitwise conjunction of the two arrays (`dst = src1 & src2`).
%
% The function calculates the per-element bit-wise logical conjunction for:
%
% * Two arrays when `src1` and `src2` have the same size:
%
%       dst(I) = src1(I) AND src2(I) if mask(I) != 0
%
% * An array and a scalar when `src2` is constructed from Scalar or has the
%   same number of elements as `size(src1,3)`:
%
%       dst(I) = src1(I) AND src2 if mask(I) != 0
%
% * A scalar and an array when `src1` is constructed from Scalar or has the
%   same number of elements as `size(src2,3)`:
%
%       dst(I) = src1 AND src2(I) if mask(I) != 0
%
% In case of floating-point arrays, their machine-specific bit representations
% (usually IEEE754-compliant) are used for the operation. In case of
% multi-channel arrays, each channel is processed independently. In the second
% and third cases above, the scalar is first converted to the array type.
%
% See also: cv.bitwise_or, cv.bitwise_xor, cv.bitwise_not, bitand
%

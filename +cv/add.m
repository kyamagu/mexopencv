%ADD  Calculates the per-element sum of two arrays or an array and a scalar
%
%     dst = cv.add(src1, src2)
%     dst = cv.add(src1, src2, 'OptionName',optionValue, ...)
%
% ## Input
% * __src1__ first input array or a scalar.
% * __src2__ second input array or a scalar.
%
% ## Output
% * __dst__ output array of the same size and number of channels as the input
%   array(s). The depth is defined by `DType` or that of `src1`/`src2`.
%
% ## Options
% * __Mask__ optional operation mask; this is an 8-bit single channel array
%   that specifies elements of the output array to be changed. Not set by
%   default.
% * __Dest__ Used to initialize the output `dst` when a mask is used. Not set
%   by default.
% * __DType__ optional depth of the output array: `uint8`, `int16`, `double`,
%   etc. (see the discussion below). Must be specified if input arrays are of
%   different types. default -1
%
% The function cv.add calculates:
%
% * Sum of two arrays when both input arrays have the same size and the same
%   number of channels:
%
%       dst(I) = saturate(src1(I) + src2(I)) if mask(I) != 0
%
% * Sum of an array and a scalar when `src2` is constructed from Scalar or has
%   the same number of elements as `size(src1,3)`:
%
%       dst(I) = saturate(src1(I) + src2) if mask(I) != 0
%
% * Sum of a scalar and an array when `src1` is constructed from Scalar or has
%   the same number of elements as `size(src2,3)`:
%
%       dst(I) = saturate(src1 + src2(I)) if mask(I) != 0
%
% where `I` is a multi-dimensional index of array elements. In case of
% multi-channel arrays, each channel is processed independently.
%
% The first function in the list above can be replaced with matrix expressions:
%
%     dst = src1 + src2;
%
% The input arrays and the output array can all have the same or different
% depths. For example, you can add a 16-bit unsigned array to a 8-bit signed
% array and store the sum as a 32-bit floating-point array. Depth of the
% output array is determined by the `DType` parameter. In the second and third
% cases above, as well as in the first case, when `class(src1)==class(src2)`,
% `DType` can be set to the default -1. In this case, the output array will
% have the same depth as the input array, be it `src1`, `src2` or both.
%
% Note: Saturation is not applied when the output array has the depth `int32.
% You may even get result of an incorrect sign in the case of overflow.
%
% See also: cv.subtract, cv.addWeighted, imadd, plus
%

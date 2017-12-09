%ADDWEIGHTED  Calculates the weighted sum of two arrays
%
%     dst = cv.addWeighted(src1, alpha, src2, beta, gamma)
%     dst = cv.addWeighted(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src1__ first input array.
% * __alpha__ weight for the first array elements.
% * __src2__ second input array of the same size and channel number as `src1`.
% * __beta__ weight for the second array elements.
% * __gamma__ scalar added to each sum.
%
% ## Output
% * __dst__ output array that has the same size and number of channels as the
%   input arrays.
%
% ## Options
% * __DType__ optional depth of the output array: `uint8`, `int16`, `double`,
%   etc. Must be specified if input arrays are of different types. When both
%   input arrays have the same depth, `DType` can be set to -1, which will be
%   equivalent to `class(src1)`. default -1
%
% The function cv.addWeighted calculates the weighted sum of two arrays as
% follows:
%
%     dst(I) = saturate(src1(I)*alpha + src2(I)*beta + gamma)
%
% where `I` is a multi-dimensional index of array elements. In case of
% multi-channel arrays, each channel is processed independently.
%
% Note: Saturation is not applied when the output array has the depth `int32`.
% You may even get result of an incorrect sign in the case of overflow.
%
% See also: cv.add, cv.subtract, cv.convertScaleAbs, imlincomb
%

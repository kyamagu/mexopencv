%MULTIPLY  Calculates the per-element scaled product of two arrays
%
%     dst = cv.multiply(src1, src2)
%     dst = cv.multiply(src1, src2, 'OptionName',optionValue, ...)
%
% ## Input
% * __src1__ first input array.
% * __src2__ second input array of the same size and type as `src1`.
%
% ## Output
% * __dst__ output array of the same size and type as `src1`.
%
% ## Options
% * __Scale__ optional scalar factor. default 1
% * __DType__ optional depth of the output array: `uint8`, `int16`, `double`,
%   etc. default -1
%
% The function cv.multiply calculates the per-element product of two arrays:
%
%     dst(I) = saturate(scale*src1(I) * src2(I))
%
% Note: Saturation is not applied when the output array has the depth `int32`.
% You may even get result of an incorrect sign in the case of overflow.
%
% See also: cv.add, cv.subtract, cv.divide, cv.addWeighted, cv.accumulate,
%  cv.accumulateProduct, cv.accumulateSquare, immultiply, times, mtimes
%

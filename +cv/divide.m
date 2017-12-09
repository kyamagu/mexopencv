%DIVIDE  Performs per-element division of two arrays or a scalar by an array
%
%     dst = cv.divide(src1, src2)
%     dst = cv.divide(src1, src2, 'OptionName',optionValue, ...)
%
% ## Input
% * __src1__ first input array.
% * __src2__ second input array of the same size and type as `src1`.
%
% ## Output
% * __dst__ output array of the same size and type as `src2`.
%
% ## Options
% * __Scale__ optional scalar factor. default 1
% * __DType__ optional depth of the output array; if -1, `dst` will have depth
%   `class(src2)`, but in case of an array-by-array division, you can only
%   pass -1 when `class(src1)==class(src2)`. default -1
%
% The function cv.divide divides one array by another:
%
%     dst(I) = saturate(src1(I)*scale / src2(I))
%
% When `src2(I)` is zero, `dst(I)` will also be zero. Different channels of
% multi-channel arrays are processed independently.
%
% Note: Saturation is not applied when the output array has the depth `int32`.
% You may even get result of an incorrect sign in the case of overflow.
%
% See also: cv.multiply, cv.add, cv.subtract, imdivide, rdivide, idivide
%

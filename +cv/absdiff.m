%ABSDIFF  Calculates the per-element absolute difference between two arrays or between an array and a scalar
%
%     dst = cv.absdiff(src1, src2)
%
% ## Input
% * __src1__ first input array or a scalar.
% * __src2__ second input array or a scalar.
%
% ## Output
% * __dst__ output array that has the same size and type as input arrays.
%
% The function cv.absdiff calculates:
%
% * Absolute difference between two arrays when they have the same size and
%   type:
%
%       dst(I) = saturate(|src1(I) - src2(I)|)
%
% * Absolute difference between an array and a scalar when the second array is
%   constructed from Scalar or has as many elements as the number of channels
%   in `src1`:
%
%       dst(I) = saturate(|src1(I) - src2|)
%
% * Absolute difference between a scalar and an array when the first array is
%   constructed from Scalar or has as many elements as the number of channels
%   in `src2`:
%
%       dst(I) = saturate(|src1 - src2(I)|)
%
% where `I` is a multi-dimensional index of array elements. In case of
% multi-channel arrays, each channel is processed independently.
%
% Note: Saturation is not applied when the arrays have the depth `int32`.
% You may even get a negative value in the case of overflow.
%
% See also: cv.subtract, imabsdiff, abs
%

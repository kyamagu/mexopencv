%COMPARE  Performs the per-element comparison of two arrays or an array and scalar value
%
%     dst = cv.compare(src1, src2, cmpop)
%
% ## Input
% * __src1__ first input array or a scalar; when it is an array, it must have
%   a single channel.
% * __src2__ second input array or a scalar; when it is an array, it must have
%   a single channel.
% * __cmpop__ comparison type, specifies correspondence between the arrays.
%   One of:
%   * __eq__ `src1` is equal to `src2`.
%   * __gt__ `src1` is greater than `src2`.
%   * __ge__ `src1` is greater than or equal to `src2`.
%   * __lt__ `src1` is less than `src2`.
%   * __le__ `src1` is less than or equal to `src2`.
%   * __ne__ `src1` is unequal to `src2`.
%
% ## Output
% * __dst__ output array of type `uint8` that has the same size and the same
%   number of channels as the input arrays.
%
% The function compares:
%
% * Elements of two arrays when `src1` and `src2` have the same size:
%
%       dst(I) = src1(I) cmpop src2(I)
%
% * Elements of `src1` with a scalar `src2` when `src2` is constructed from
%   Scalar or has a single element:
%
%       dst(I) = src1(I) cmpop src2
%
% * `src1` with elements of `src2` when `src1` is constructed from Scalar or
%   has a single element:
%
%       dst(I) = src1 cmpop src2(I)
%
% When the comparison result is true, the corresponding element of output
% array is set to 255. The comparison operations can be replaced with the
% equivalent matrix expressions:
%
%     dst1 = src1 >= src2;
%     dst2 = src1 < 8;
%     ...
%
% See also: cv.threshold, eq, gt, ge, lt, le, ne, min, max
%

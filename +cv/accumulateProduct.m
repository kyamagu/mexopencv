%ACCUMULATEPRODUCT  Adds the per-element product of two input images to the accumulator
%
%    dst = cv.accumulateProduct(src1, src2, dst)
%    dst = cv.accumulateProduct(src1, src2, dst, 'OptionName',optionValue, ...)
%
% ## Input
% * __src1__ First input image, 1- or 3-channel, 8-bit or 32-bit floating
%       point.
% * __src2__ Second input image of the same type and the same size as `src1`.
% * __dst__ Input accumulator with the same number of channels as input
%       images, 32-bit or 64-bit floating-point.
%
% ## Output
% * __dst__ Output accumulator image.
%
% ## Options
% * __mask__ Optional operation mask. Not set by default
%
% The function adds the product of two images or their selected regions to the
% accumulator `dst`:
%
%    dst(x,y) = dst(x,y) + src1(x,y)*src2(x,y)  if mask(x,y)~=0
%
% The function supports multi-channel images. Each channel is processed
% independently.
%
% See also: cv.accumulate, cv.accumulateSquare, cv.accumulateWeighted
%

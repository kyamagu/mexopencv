%ACCUMULATEWEIGHTED  Updates a running average
%
%    dst = cv.accumulateWeighted(src, dst, alpha)
%    dst = cv.accumulateWeighted(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input image as 1- or 3-channel, 8-bit or 32-bit floating point.
% * __dst__ Input accumulator image with the same number of channels as input
%       image, 32-bit or 64-bit floating-point.
% * __alpha__ Weight of the input image. A scalar double.
%
% ## Output
% * __dst__ Output accumulator image.
%
% ## Options
% * __mask__ Optional operation mask. Not set by default
%
% The function calculates the weighted sum of the input image `src` and the
% accumulator `dst` so that `dst` becomes a running average of a frame
% sequence:
%
%    dst(x,y) = (1-alpha)*dst(x,y) + alpha*src(x,y)  if mask(x,y)~=0
%
% That is, `alpha` regulates the update speed (how fast the accumulator
% "forgets" about earlier images). The function supports multi-channel images.
% Each channel is processed independently.
%
% See also: cv.accumulate, cv.accumulateSquare, cv.accumulateProduct
%

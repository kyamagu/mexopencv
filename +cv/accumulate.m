%ACCUMULATE  Adds an image to the accumulator
%
%    dst = cv.accumulate(src, dst)
%    dst = cv.accumulate(src, dst, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input image as 1- or 3-channel, 8-bit or 32-bit floating point.
% * __dst__ Input accumulator image with the same number of channels as input
%       image, 32-bit or 64-bit floating-point.
%
% ## Output
% * __dst__ Output accumulator image.
%
% ## Options
% * __mask__ Optional operation mask. Not set by default
%
% The function adds `src` or some of its elements to `dst`:
%
%    dst(x,y) = dst(x,y) + src(x,y)  if mask(x,y)~=0
%
% The function supports multi-channel images. Each channel is processed
% independently.
%
% The functions accumulate* can be used, for example, to collect statistics
% of a scene background viewed by a still camera and for the further
% foreground-background segmentation.
%
% See also: cv.accumulateSquare, cv.accumulateProduct, cv.accumulateWeighted
%

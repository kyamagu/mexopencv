%ACCUMULATE  Adds an image to the accumulator image
%
%     dst = cv.accumulate(src, dst)
%     dst = cv.accumulate(src, dst, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input image of type `uint8`, `uint16`, `single`, or `double`, with
%   any number of channels
% * __dst__ Input accumulator image with the same number of channels as input
%   image, and a depth of `single` or `double`.
%
% ## Output
% * __dst__ Output accumulator image.
%
% ## Options
% * __mask__ Optional operation mask. Not set by default
%
% The function adds `src` or some of its elements to `dst`:
%
%     dst(x,y) = dst(x,y) + src(x,y)  if mask(x,y)~=0
%
% The function supports multi-channel images. Each channel is processed
% independently.
%
% The function cv.accumulate can be used, for example, to collect statistics
% of a scene background viewed by a still camera and for the further
% foreground-background segmentation.
%
% See also: cv.accumulateSquare, cv.accumulateProduct, cv.accumulateWeighted
%

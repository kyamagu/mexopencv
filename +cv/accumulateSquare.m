%ACCUMULATESQUARE  Adds the square of a source image to the accumulator image
%
%     dst = cv.accumulateSquare(src, dst)
%     dst = cv.accumulateSquare(src, dst, 'OptionName',optionValue, ...)
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
% The function adds the input image `src` or its selected region, raised to a
% power of 2, to the accumulator `dst`:
%
%     dst(x,y) = dst(x,y) + src(x,y)^2  if mask(x,y)~=0
%
% The function supports multi-channel images. Each channel is processed
% independently.
%
% See also: cv.accumulate, cv.accumulateProduct, cv.accumulateWeighted
%

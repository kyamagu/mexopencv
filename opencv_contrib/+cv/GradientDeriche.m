%GRADIENTDERICHE  Applies Deriche filter to an image
%
%     dst = cv.GradientDeriche(op, dir)
%     dst = cv.GradientDeriche(op, dir, 'OptionName',optionValue, ...)
%
% ## Input
% * __op__ Source 8-bit or 16-bit image, 1-channel or 3-channel image.
% * __dir__ Filter direction. One of:
%   * __X__
%   * __Y__
%
% ## Output
% * __dst__ result `single` image with same number of channel than `op`.
%
% ## Options
% * __AlphaDerive__ double see paper. default 1.0
% * __AlphaMean__ double see paper. default 1.0
%
% For more details about this implementation, please see [deriche1987].
%
% ## References
% [deriche1987]:
% > Rachid Deriche. "Using Canny's criteria to derive a recursively
% > implemented optimal edge detector". International Journal of Computer
% > Vision, Volume 1 Issue 2, pages 167-187, 1987.
% > http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.476.5736&rep=rep1&type=pdf
%
% See also: imgradientxy
%

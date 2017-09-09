%GRADIENTPAILLOU  Applies Paillou filter to an image
%
%     dst = cv.GradientPaillou(op, dir)
%     dst = cv.GradientPaillou(op, dir, 'OptionName',optionValue, ...)
%
% ## Input
% * __op__ Source 8-bit or 16-bit image, 1-channel or 3-channel image.
% * __dir__ Gradient direction. One of:
%   * __X__
%   * __Y__
%
% ## Output
% * __dst__ result `single` image with same number of channel than `op`.
%
% ## Options
% * __Alpha__ double see paper. default 1.0
% * __Omega__ double see paper. default 0.1
%
% For more details about this implementation, please see
% [paillou1997detecting].
%
% ## References
% [paillou1997detecting]:
% > Philippe Paillou. "Detecting step edges in noisy SAR images: a new linear
% > operator". IEEE transactions on geoscience and remote sensing,
% > 35(1):191-196, 1997.
%
% See also: imgradientxy
%

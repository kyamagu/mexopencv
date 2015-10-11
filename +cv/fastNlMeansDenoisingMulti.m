%FASTNLMEANSDENOISINGMULTI  Modification of fastNlMeansDenoising function for colored images sequences
%
%    dst = cv.fastNlMeansDenoisingMulti(srcImgs, imgToDenoiseIndex, temporalWindowSize)
%    dst = cv.fastNlMeansDenoisingMulti(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __srcImgs__ Input 8-bit (or 16-bit with 'L1' norm) 1-channel, 2-channel,
%       3-channel or 4-channel images sequence. All images should have the
%       same type and size.
% * __imgToDenoiseIndex__ Target image to denoise index in `srcImgs` sequence
%       (0-based index).
% * __temporalWindowSize__ Number of surrounding images to use for target
%       image denoising. Should be odd. Images from
%       `imgToDenoiseIndex - temporalWindowSize/2` to
%       `imgToDenoiseIndex + temporalWindowSize/2` from `srcImgs` will be used
%       to denoise `srcImgs{imgToDenoiseIndex}` image.
%
% ## Output
% * __dst__ Output image with the same size and type as `srcImgs` images.
%
% ## Options
% * __H__ Array of parameters regulating filter strength, either one parameter
%       applied to all channels or one value per channel in `dst`. Big `H`
%       value perfectly removes noise but also removes image details, smaller
%       `H` value preserves details but also preserves some noise. default [3]
% * __TemplateWindowSize__ Size in pixels of the template patch that is used
%       to compute weights. Should be odd. Recommended value 7 pixels.
%       default 7
% * __SearchWindowSize__ Size in pixels of the window that is used to compute
%       weighted average for given pixel. Should be odd. Affect performance
%       linearly: greater `SearchWindowsSize` - greater denoising time.
%       Recommended value 21 pixels. default 21
% * __NormType__ Type of norm used for weight calculation. Can be either:
%       * __L2__ (default)
%       * __L1__
%
% Modification of cv.fastNlMeansDenoising function for images sequence where
% consequtive images have been captured in small period of time. For example
% video. This version of the function is for grayscale images or for manual
% manipulation with colorspaces. For more details see:
% http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.131.6394
%
% See also: cv.fastNlMeansDenoising, cv.fastNlMeansDenoisingColored,
%  cv.fastNlMeansDenoisingColoredMulti
%

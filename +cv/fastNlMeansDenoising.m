%FASTNLMEANSDENOISING  Image denoising using Non-local Means Denoising algorithm
%
%    dst = cv.fastNlMeansDenoising(src)
%    dst = cv.fastNlMeansDenoising(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit (or 16-bit with `L1` norm) 1-channel, 2-channel,
%       3-channel or 4-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
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
% Perform image denoising using Non-local Means Denoising algorithm
% http://www.ipol.im/pub/algo/bcm_non_local_means_denoising/ with several
% computational optimizations. Noise expected to be a gaussian white noise.
%
% This function expected to be applied to grayscale images. For colored images
% look at cv.fastNlMeansDenoisingColored. Advanced usage of this functions can
% be manual denoising of colored image in different colorspaces. Such approach
% is used in cv.fastNlMeansDenoisingColored by converting image to CIELAB
% colorspace and then separately denoise L and AB components with different
% `H` parameter.
%
% See also: cv.fastNlMeansDenoisingColored, cv.fastNlMeansDenoisingMulti,
%  cv.fastNlMeansDenoisingColoredMulti
%

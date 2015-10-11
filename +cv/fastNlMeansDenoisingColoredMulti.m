%FASTNLMEANSDENOISINGCOLOREDMULTI  Modification of fastNlMeansDenoisingMulti function for colored images sequences
%
%    dst = cv.fastNlMeansDenoisingColoredMulti(srcImgs, imgToDenoiseIndex, temporalWindowSize)
%    dst = cv.fastNlMeansDenoisingColoredMulti(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __srcImgs__ Input 8-bit 3-channel images sequence. All images should have
%       the same type and size.
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
% * __H__ Parameter regulating filter strength for luminance component. Bigger
%       `H` value perfectly removes noise but also removes image details,
%       smaller `H` value preserves details but also preserves some noise.
%       default 3
% * __HColor__ The same as `H` but for color components. default 3
% * __TemplateWindowSize__ Size in pixels of the template patch that is used
%       to compute weights. Should be odd. Recommended value 7 pixels.
%       default 7
% * __SearchWindowSize__ Size in pixels of the window that is used to compute
%       weighted average for given pixel. Should be odd. Affect performance
%       linearly: greater `SearchWindowsSize` - greater denoising time.
%       Recommended value 21 pixels. default 21
% * __FlipChannels__ whether to flip the order of color channels in input
%       `srcImgs{i}` and output `dst`, between MATLAB's RGB/RGBA order and
%       OpenCV's BGR/BGRA (input: RGB/RGBA->BGR/BGRA,
%       output: BGR/BGRA->RGB/RGBA). default true
%
% The function converts images to CIELAB colorspace and then separately
% denoise L and AB components with given `H` parameters using
% cv.fastNlMeansDenoisingMulti function.
%
% See also: cv.fastNlMeansDenoising, cv.fastNlMeansDenoisingColored,
%  cv.fastNlMeansDenoisingMulti
%

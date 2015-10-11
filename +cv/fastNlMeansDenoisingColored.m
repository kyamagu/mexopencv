%FASTNLMEANSDENOISINGCOLORED  Modification of fastNlMeansDenoising function for colored images
%
%    dst = cv.fastNlMeansDenoisingColored(src)
%    dst = cv.fastNlMeansDenoisingColored(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel or 4-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
%
% ## Options
% * __H__ Parameter regulating filter strength for luminance component. Bigger
%       `H` value perfectly removes noise but also removes image details,
%       smaller `H` value preserves details but also preserves some noise.
%       default 3
% * __HColor__ The same as `H` but for color components. For most images value
%       equals 10 will be enough to remove colored noise and do not distort
%       colors. default 3
% * __TemplateWindowSize__ Size in pixels of the template patch that is used
%       to compute weights. Should be odd. Recommended value 7 pixels.
%       default 7
% * __SearchWindowSize__ Size in pixels of the window that is used to compute
%       weighted average for given pixel. Should be odd. Affect performance
%       linearly: greater `SearchWindowsSize` - greater denoising time.
%       Recommended value 21 pixels. default 21
% * __FlipChannels__ whether to flip the order of color channels in input
%       `src` and output `dst`, between MATLAB's RGB/RGBA order and
%       OpenCV's BGR/BGRA (input: RGB/RGBA->BGR/BGRA,
%       output: BGR/BGRA->RGB/RGBA). default true
%
% The function converts image to CIELAB colorspace and then separately denoise
% L and AB components with given `H` parameters using cv.fastNlMeansDenoising
% function.
%
% See also: cv.fastNlMeansDenoising, cv.fastNlMeansDenoisingMulti,
%  cv.fastNlMeansDenoisingColoredMulti
%

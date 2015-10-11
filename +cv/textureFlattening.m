%TEXTUREFLATTENING  Texture Flattening
%
%    dst = cv.textureFlattening(src, mask)
%    dst = cv.textureFlattening(src, mask, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
% * __mask__ Input 8-bit 1 or 3-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
%
% ## Options
% * __LowThreshold__ Range from 0 to 100. default 30
% * __HighThreshold__ Value > 100. default 45
% * __KernelSize__ The size of the Sobel kernel to be used. default 3
% * __FlipChannels__ whether to flip the order of color channels in inputs
%       `src` and `mask` and output `dst`, between MATLAB's RGB order and
%       OpenCV's BGR (input: RGB->BGR, output: BGR->RGB). default true
%
% By retaining only the gradients at edge locations, before integrating with
% the Poisson solver, one washes out the texture of the selected region,
% giving its contents a flat aspect. Here Canny Edge Detector is used.
%
% ## Note
% The algorithm assumes that the color of the source image is close to that of
% the destination. This assumption means that when the colors don't match, the
% source image color gets tinted toward the color of the destination image.
%

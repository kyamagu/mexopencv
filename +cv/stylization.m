%STYLIZATION  Stylization filter
%
%    dst = cv.stylization(src)
%    dst = cv.stylization(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
%
% ## Options
% * __SigmaS__ Range between 0 to 200. default 60
% * __SigmaR__ Range between 0 to 1. default 0.45
% * __FlipChannels__ whether to flip the order of color channels in input
%       `src` and output `dst`, between MATLAB's RGB order and OpenCV's BGR
%       (input: RGB->BGR, output: BGR->RGB). default true
%
% Stylization aims to produce digital imagery with a wide variety of effects
% not focused on photorealism. Edge-aware filters are ideal for stylization,
% as they can abstract regions of low contrast while preserving, or enhancing,
% high-contrast features.
%

%PENCILSKETCH  Pencil-like non-photorealistic line drawing
%
%    [dst1,dst2] = cv.pencilSketch(src)
%    [dst1,dst2] = cv.pencilSketch(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
%
% ## Output
% * __dst1__ Output 8-bit 1-channel image.
% * __dst2__ Output image with the same size and type as `src`.
%
% ## Options
% * __SigmaS__ Range between 0 to 200. default 60
% * __SigmaR__ Range between 0 to 1. default 0.07
% * __ShadeFactor__ Range between 0 to 0.1. default 0.02
% * __FlipChannels__ whether to flip the order of color channels in input
%       `src` and output `dst2`, between MATLAB's RGB order and OpenCV's BGR
%       (input: RGB->BGR, output: BGR->RGB). default true
%

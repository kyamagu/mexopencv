%COLORCHANGE  Color Change
%
%    dst = cv.colorChange(src, mask)
%    dst = cv.colorChange(src, mask, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
% * __mask__ Input 8-bit 1 or 3-channel image.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
%
% ## Options
% * __R__ R-channel multiply factor. default 1.0
% * __G__ G-channel multiply factor. default 1.0
% * __B__ B-channel multiply factor. default 1.0
% * __FlipChannels__ whether to flip the order of color channels in inputs
%       `src` and `mask` and output `dst`, between MATLAB's RGB order and
%       OpenCV's BGR (input: RGB->BGR, output: BGR->RGB). default true
%
% Given an original color image, two differently colored versions of this
% image can be mixed seamlessly.
%
% Multiplication factors are between 0.5 to 2.5
%

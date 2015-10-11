%DECOLOR  Transforms a color image to a grayscale image
%
%    [grayscale,color_boost] = cv.decolor(src)
%    [grayscale,color_boost] = cv.decolor(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel color image.
%
% ## Output
% * __grayscale__ Output 8-bit 1-channel grayscale image.
% * **color_boost** Output 8-bit 3-channel contrast-boosted color image.
%       It is obtained by converting `src` to Lab color space, replacing the
%       lightness channel with `grayscale`, and converting back to RGB color
%       space.
%
% ## Options
% * __FlipChannels__ whether to flip the order of color channels in input
%       `src` and output `color_boost`, between MATLAB's RGB order and
%       OpenCV's BGR (input: RGB->BGR, output: BGR->RGB). default true
%
% It is a basic tool in digital printing, stylized black-and-white photograph
% rendering, and in many single channel image processing applications [CL12].
%
% This function is to be applied on color images.
%
% ## References
% [CL12]:
% > Cewu Lu, Li Xu, and Jiaya Jia. "Contrast preserving decolorization".
% > In Computational Photography (ICCP), 2012 IEEE International Conference
% > on, pages 1-7. IEEE, 2012.
%
% See also: cv.cvtColor
%

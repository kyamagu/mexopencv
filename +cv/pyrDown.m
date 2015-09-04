%PYRDOWN  Blurs an image and downsamples it
%
%    dst = cv.pyrDown(src)
%    dst = cv.pyrDown(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input image; `uint8`, `uint16`, `int16`, `single`, or `double`.
%
% ## Output
% * __dst__ Destination image. It has the specified size and the same type
%       as `src`.
%
% ## Options
% * __DstSize__ Size of the output image `[w,h]`. default [0,0], see below.
% * __BorderType__ Pixel extrapolation method, see cv.copyMakeBorder
%       ('Constant' isn't supported). Default 'Default'
%
% By default, size of the output image is computed as
% `[(size(src,2)+1)/2 (size(src,1)+1)/2]`, but in any case, the following
% conditions should be satisfied:
%
%    abs(DstSize(2)*2 - size(src,2)) <= 2
%    abs(DstSize(1)*2 - size(src,1)) <= 2
%
% The function performs the downsampling step of the Gaussian pyramid
% construction. First, it convolves the source image with the kernel:
%
%    1/256 * [1  4  6  4  1;
%             4 16 24 16  4;
%             6 24 34 24  6;
%             4 16 24 16  4;
%             1  4  6  4  1]
%
% Then, it downsamples the image by rejecting even rows and columns.
%
% See also: cv.pyrUp, cv.buildPyramid
%

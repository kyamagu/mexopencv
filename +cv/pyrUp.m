%PYRUP  Upsamples an image and then blurs it
%
%    dst = cv.pyrUp(src)
%    dst = cv.pyrUp(src, 'OptionName',optionValue, ...)
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
% `[size(src,2)*2 size(src,1)*2]`, but in any case, the following conditions
% should be satisfied:
%
%    abs(DstSize(2) - size(src,2)*2) <= mod(DstSize(2),2)
%    abs(DstSize(1) - size(src,1)*2) <= mod(DstSize(1),2)
%
% The function performs the upsampling step of the Gaussian pyramid
% construction, though it can actually be used to construct the Laplacian
% pyramid. First, it upsamples the source image by injecting even zero rows
% and columns and then convolves the result with the same kernel as in
% cv.pyrDown multiplied by 4.
%
% See also: cv.pyrDown, cv.buildPyramid
%

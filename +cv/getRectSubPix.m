%GETRECTSUBPIX  Retrieves a pixel rectangle from an image with sub-pixel accuracy
%
%    dst = cv.getRectSubPix(src, patchSize, center)
%    dst = cv.getRectSubPix(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image, 8-bit integer or 32-bit floating-point, 1- or
%       3-channels.
% * __patchSize__ Size of the extracted patch `[w,h]`.
% * __center__ Floating point coordinates of the center of the extracted
%       rectangle within the source image. The center `[x,y]` must be inside
%       the image.
%
% ## Output
% * __dst__ Extracted patch that has the size `PatchSize`, the same number
%       of channels as `src`, and the specified type in `PatchType`.
%
% ## Options
% * __PatchType__ Depth of the extracted pixels. By default (-1), they have
%       the same depth as `src`. Supports either `uint8` or `single`.
%
% The function cv.getRectSubPix extracts pixels from `src`:
%
%    dst(x,y) = src(x + center(1) - (size(dst,2)-1)*0.5,
%                   y + center(2) - (size(dst,1)-1)*0.5)
%
% where the values of the pixels at non-integer coordinates are retrieved using
% bilinear interpolation. Every channel of multi-channel images is processed
% independently. While the center of the rectangle must be inside the image,
% parts of the rectangle may be outside. In this case, the replication border
% mode is used to extrapolate the pixel values outside of the image.
%
% See also: cv.warpAffine, cv.warpPerspective
%

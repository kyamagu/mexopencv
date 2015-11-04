%INPAINT2  The function implements different single-image inpainting algorithms
%
%    dst = cv.inpaint2(src, mask)
%    dst = cv.inpaint2(src, mask, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ source image, it could be of any type (8/16/32-bit integers or
%       32/64-bit floating points) and any number of channels from 1 to 4. In
%       case of 3- and 4-channels images the function expect them in CIELab
%       colorspace or similar one, where first color component shows
%       intensity, while second and third shows colors. Nonetheless you can
%       try any colorspaces.
% * __mask__ mask (8-bit 1-channel of same size as `src`), where non-zero
%       pixels indicate valid image area, while zero pixels indicate area to
%       be inpainted.
%
% ## Output
% * __dst__ Output image with the same size and type as `src`.
%
% ## Options
% * __Method__ Inpainting algorithms, one of:
%       * __ShiftMap__ (default) This algorithm searches for dominant
%             correspondences (transformations) of image patches and tries to
%             seamlessly fill-in the area to be inpainted using this
%             transformations.
%
% The function reconstructs the selected image area from known area.
% See the original paper [He2012] for details.
%
% ## References
% [He2012]:
% > Kaiming He, Jian Sun. "Statistics of patch offsets for image completion".
% > In Computer Vision-ECCV 2012, pages 16-29. Springer, 2012.
%
% See also: cv.inpaint
%

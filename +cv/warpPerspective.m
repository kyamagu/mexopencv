%WARPPERSPECTIVE  Applies a perspective transformation to an image
%
%    dst = cv.warpPerspective(src, M)
%    dst = cv.warpPerspective(src, M, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input image.
% * __M__ 3x3 transformation matrix, floating-point.
%
% ## Output
% * __dst__ Output image that has the size `DSize` (with
%       `size(dst,3) == size(src,3)`) and the same type as `src`.
%
% ## Options
% * __DSize__ Size of the output image `[w,h]`. Default `[0,0]` means using
%       the same size as the input `[size(src,2) size(src,1)]`.
% * __Interpolation__ interpolation method, default 'Linear'. One of:
%       * __Nearest__ nearest neighbor interpolation
%       * __Linear__ bilinear interpolation
%       * __Cubic__ bicubic interpolation
%       * __Lanczos4__ Lanczos interpolation over 8x8 neighborhood
% * __WarpInverse__ Logical flag to apply inverse perspective transform,
%       meaning that `M` is the inverse transformation (`dst -> src`).
%       default false
% * __BorderType__ Pixel extrapolation method. When 'Transparent', it means
%       that the pixels in the destination image corresponding to the
%       "outliers" in the source image are not modified by the function.
%       default 'Constant'
%       * __Constant__ `iiiiii|abcdefgh|iiiiiii` with some specified `i`
%       * __Replicate__ `aaaaaa|abcdefgh|hhhhhhh`
%       * __Reflect__ `fedcba|abcdefgh|hgfedcb`
%       * __Reflect101__ `gfedcb|abcdefgh|gfedcba`
%       * __Wrap__ `cdefgh|abcdefgh|abcdefg`
%       * __Transparent__ `uvwxyz|absdefgh|ijklmno`
%       * __Default__ same as 'Reflect101'
% * __BorderValue__ Value used in case of a constant border. default 0
% * __Dst__ Optional initial image for the output. If not set, it is
%       automatically created by the function. Note that it must match the
%       expected size `DSize` and the type of `src`, otherwise it is ignored
%       and recreated by the function. This option is only useful when
%       `BorderType=Transparent`, in which case the transformed image is drawn
%       onto the existing `Dst` without extrapolating pixels. Not set by
%       default.
%
% The function cv.warpPerspective transforms the source image using the
% specified matrix:
%
%     dst(x,y) = src((M_11*x + M_12*y + M_13) / (M_31*x + M_32*y + M_33),
%                    (M_21*x + M_22*y + M_23) / (M_31*x + M_32*y + M_33))
%
% when the `WarpInverse` option is true. Otherwise, the transformation is
% first inverted with cv.invert and then put in the formula above instead of
% `M`.
%
% See also: cv.warpAffine, cv.remap, cv.resize, cv.getRectSubPix,
%  cv.perspectiveTransform, imtransform, imwarp
%

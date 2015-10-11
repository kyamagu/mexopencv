%REMAP  Applies a generic geometrical transformation to an image
%
%    dst = cv.remap(src, map1, map2)
%    dst = cv.remap(src, map1)
%    dst = cv.remap(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source image.
% * __map1__ The first map of either (x,y) points or just x values of the
%       transformation having the type `int16` (2-channels), `single`
%       (1-channels), or `single` (2-channels). See cv.convertMaps for details
%       on converting a floating-point representation to fixed-point for speed.
% * __map2__ The second map of y values of the transformation having the type
%       `uint16` (1-channel) or `single` (1-channel), or none (empty map if
%       `map1` is (x,y) points), respectively.
%
% In other words, the following map combinations are valid:
%
% * *separate floating-point representation*: `map1` as NxMx1 `single` matrix,
%   and `map2` as NxMx1 `single` matrix
% * *combined floating-point representation*: `map1` as NxMx2 `single` array,
%   and unspecified/empty `map2`. This is equivalent to `map1=cat(3,map1,map2)`
%   from the separate floating-point representation.
% * *fixed-point representation*: `map1` as `NxMx2` `int16` array, and `map2`
%   as `NxMx1` `uint16` matrix, converted from the floating-point
%   representation using cv.convertMaps.
%
% ## Output
% * __dst__ Destination image. It has the same row/column size as `map1` and
%       the same type as `src`.
%
% ## Options
% * __Interpolation__ interpolation method, default 'Linear'. One of:
%       * __Nearest__ a nearest-neighbor interpolation
%       * __Linear__ a bilinear interpolation (used by default)
%       * __Cubic__ a bicubic interpolation over 4x4 pixel neighborhood
%       * __Lanczos4__ a Lanczos interpolation over 8x8 pixel neighborhood
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
%       row/column size of `map1` and the type of `src`, otherwise it is
%       ignored and recreated by the function. This option is only useful when
%       `BorderType=Transparent`, in which case the transformed image is drawn
%       onto the existing `Dst` without extrapolating pixels. Not set by
%       default.
%
% The function cv.remap transforms the source image using the specified map:
%
%     dst(x,y) = src(mapX(x,y), mapY(x,y))
%
% where values of pixels with non-integer coordinates are computed using one
% of available interpolation methods. `mapX` and `mapY` can be encoded as
% separate floating-point maps in `map1` and `map2` respectively, or
% interleaved floating-point maps of (x,y) in `map1`, or fixed-point maps
% created by using cv.convertMaps. The reason you might want to convert from
% floating to fixed-point representations of a map is that they can yield much
% faster (2x) remapping operations. In the converted case, `map1` contains
% pairs `(floor(x), floor(y))` and `map2` contains indices in a table of
% interpolation coefficients.
%
% See also: cv.convertMaps, interp2, imwarp
%

%FLOODFILL  Fills a connected component with the given color
%
%     [dst, rect, area] = cv.floodFill(src, seed, newVal)
%     [dst, rect, area, mask] = cv.floodFill(..., 'Mask',mask, 'MaskOnly',true)
%     [...] = cv.floodFill(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 1- or 3-channel, 8-bit, or floating-point image.
% * __seed__ Starting seed point `[x,y]`.
% * __newVal__ New value of the repainted domain pixels. It should match the
%   range and dimensions of the input image: 1-element vector (brightness)
%   for grayscale images, and 3-element vector (color) for RGB images.
%
% ## Output
% * __dst__ Destination image of the same size and the same type as `src`.
%   Contains the modified input unless the `MaskOnly` flag is set in the
%   second variant of the function, in which case `dst` is the same as the
%   input `src` unmodified. See the details below.
% * __rect__ Optional output parameter set by the function to the minimum
%   bounding rectangle of the repainted domain `[x,y,w,h]`.
% * __area__ Optional output parameter set by the function to the number of
%   filled pixels.
% * __mask__ Optional output containing the updated input `Mask`. Populated in
%   the second variant of the function with the `Mask` option. On output,
%   pixels in the mask corresponding to filled pixels in the image are set
%   to 1 or to the value specified in `MaskFillValue` option as described
%   below. Additionally, the function fills the border of the mask with ones
%   to simplify internal processing. It is therefore possible to use the same
%   mask in multiple calls to the function to make sure the filled areas do
%   not overlap.
%
% ## Options
% * __LoDiff__ Maximal lower brightness/color difference between the currently
%   observed pixel and one of its neighbors belonging to the component, or a
%   seed pixel being added to the component. default zeros
% * __UpDiff__ Maximal upper brightness/color difference between the currently
%   observed pixel and one of its neighbors belonging to the component, or a
%   seed pixel being added to the component. default zeros
% * __Connectivity__ Connectivity value, 4 or 8. The default value of 4 means
%   that only the four nearest neighbor pixels (those that share an edge are
%   considered. A connectivity value of 8 means that the eight nearest
%   neighbor pixels (those that share a corner) will be considered. default 4
% * __FixedRange__ If set, the difference between the current pixel and seed
%   pixel is considered. Otherwise, the difference between neighbor pixels is
%   considered (that is, the range is floating). This determines whether to
%   fill relative to the seed point pixel, or to fill relative the neighbor's
%   value). default false
% * __Mask__ Operation mask that should be a single-channel 8-bit image, 2
%   pixels wider and 2 pixels taller than image. Flood-filling cannot go
%   across non-zero pixels in the input mask. For example, an edge detector
%   output can be used as a mask to stop filling at edges. Not set by default.
% * __MaskOnly__ If set, the function does not change the image in the output
%   (`newVal` is ignored), and only fills the output `mask` with the value
%   specified in `MaskFillValue` as described. This option only make sense in
%   function variants that have the mask parameter. default false
% * __MaskFillValue__ Value between 1 and 255 with which to fill the output
%   `Mask`. This option only make sense in function variants that have the
%   mask parameter. default 0 (which effectively flood-fills the mask by the
%   default filling value of 1)
%
% The function cv.floodFill fills a connected component starting from the seed
% point with the specified color. The connectivity is determined by the
% color/brightness closeness of the neighbor pixels.
%
% The pixel at `(x,y)` is considered to belong to the repainted domain if:
%
% * in case of a grayscale image and floating range:
%
%       src(x',y') - LoDiff <= src(x,y) <= src(x',y') + UpDiff
%
% * in case of a grayscale image and fixed range:
%
%       src(seed.x,seed.y) - LoDiff <= src(x,y) <= src(seed.x,seed.y) + UpDiff
%
% * in case of a color image and floating range:
%   (a conjuction over all channels of the same condition as before)
%
%       src(x',y',1) - LoDiff(1) <= src(x,y,1) <= src(x',y',1) + UpDiff(1), and
%       src(x',y',2) - LoDiff(2) <= src(x,y,2) <= src(x',y',2) + UpDiff(2), and
%       src(x',y',3) - LoDiff(3) <= src(x,y,3) <= src(x',y',3) + UpDiff(3)
%
% * in case of a color image and fixed range:
%   (a conjuction over all channels of the same condition as before)
%
%       src(seed.x,seed.y,1) - LoDiff(1) <= src(x,y,1) <= src(seed.x,seed.y,1) + UpDiff(1),
%       src(seed.x,seed.y,2) - LoDiff(2) <= src(x,y,2) <= src(seed.x,seed.y,2) + UpDiff(2),
%       src(seed.x,seed.y,3) - LoDiff(3) <= src(x,y,3) <= src(seed.x,seed.y,3) + UpDiff(3)
%
% where `src(x',y')` is the value of one of pixel neighbors that is already
% known to belong to the component. That is, to be added to the connected
% component, a color/brightness of the pixel should be close enough to:
%
% * Color/brightness of one of its neighbors that already belong to the
%   connected component in case of a floating range.
% * Color/brightness of the seed point in case of a fixed range.
%
% Use this function to either mark a connected component with the specified
% color, or build a mask and then extract the contour, or copy the region to
% another image, and so on.
%
% **Note:** Since the mask is larger than the filled image, a pixel `(x,y)` in
% image corresponds to the pixel `(x+1,y+1)` in the mask.
%
% See also: cv.findContours, imfill, grayconnected, bwselect, roicolor
%

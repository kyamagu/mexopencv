%RESIZE  Resizes an image
%
%    dst = cv.resize(src, dsize)
%    dst = cv.resize(src, fx, fy)
%    dst = cv.resize(..., 'Interpolation', interpolation)
%
% ## Input
% * __src__ input image.
% * __dsize__ output image size `[w,h]`.
% * __fx__ Scale factors along the horizontal axis.
% * __fy__ Scale factors along the vertical axis.
%
% When scale factors are specified, the output image size is computed as:
% `dsize = round([fx*size(src,2), fy*size(src,1)])`.
%
% ## Output
% * __dst__ output image. It has the size `dsize` or the size computed from
%       `size(src)` and `fx` and `fy`. The type of `dst` is the same as of
%       `src`.
%
% ## Options
% * __Interpolation__ interpolation method, default 'Linear'. One of:
%       * __Nearest__ a nearest-neighbor interpolation
%       * __Linear__ a bilinear interpolation (used by default)
%       * __Cubic__ a bicubic interpolation over 4x4 pixel neighborhood
%       * __Area__ resampling using pixel area relation. It may be a preferred
%             method for image decimation, as it gives moire-free results. But
%             when the image is zoomed, it is similar to the 'Nearest' method.
%       * __Lanczos4__ a Lanczos interpolation over 8x8 pixel neighborhood
%
% The function cv.resize resizes the image `src` down to or up to the
% specified size. The size and type of `dst` are derived from `src`, `dsize`,
% `fx` and `fy`. If you want to resize `src` so that it fits a specified size,
% you may call the function as follows:
%
%    dst = cv.resize(src, [w,h], 'Interpolation',interp)
%
% If you want to decimate the image by factor of 2 in each direction, you can
% call the function this way:
%
%    dst = cv.resize(src, 0.5, 0.5, 'Interpolation',interp)
%
% To shrink an image, it will generally look best with 'Area' interpolation,
% whereas to enlarge an image, it will generally look best with 'Cubic' (slow)
% or 'Linear' (faster but still looks OK).
%
% See also: cv.warpAffine, cv.warpPerspective, cv.remap, imresize
%

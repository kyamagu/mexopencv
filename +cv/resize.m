%RESIZE  Resizes an image
%
%    dst = cv.resize(src, scale)
%    dst = cv.resize(src, siz)
%    dst = cv.resize(src, scale, 'Interpolation', interpolation)
%
% ## Input
% * __src__ Source image.
% * __siz__ Destination image size.
% * __scale__ Scale factor along both x and y axis.
%
% ## Output
% * __dst__ Destination image. It has the size siz or the size computed from
%        size(src) and scale. The type of dst is the same as of src.
%
% ## Options
% * __Interpolation__ interpolation method. default: 'Linear'
% * __Nearest__ a nearest-neighbor interpolation
% * __Linear__ a bilinear interpolation (used by default)
% * __Area__ resampling using pixel area relation. It may be a preferred
%                  method for image decimation, as it gives moire-free results.
%                  But when the image is zoomed, it is similar to the 'Nearest'
%                  method.
% * __Cubic__ a bicubic interpolation over 4x4 pixel neighborhood
% * __Lanczos4__ a Lanczos interpolation over 8x8 pixel neighborhood
%
% The function resize resizes the image src down to or up to the specified size.
%
% To shrink an image, it will generally look best with 'Area' interpolation,
% whereas to enlarge an image, it will generally look best with 'Cubic' (slow)
% or 'Linear' (faster but still looks OK).
%
% See also cv.warpAffine cv.warpPerspective
%

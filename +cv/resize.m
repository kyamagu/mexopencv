%RESIZE  Resizes an image
%
%    dst = resize(src, scale)
%    dst = resize(src, siz)
%    dst = resize(src, scale, 'Interpolation', interpolation)
%
%  Input:
%    src: Source image.
%    siz: Destination image size.
%    scale: Scale factor along both x and y axis.
%  Output:
%    dst: Destination image. It has the size siz or the size computed from
%         size(src) and scale. The type of dst is the same as of src.
%  Options:
%    'Interpolation': interpolation method. default: 'Linear'
%      'Nearest':  a nearest-neighbor interpolation
%      'Linear':   a bilinear interpolation (used by default)
%      'Area':     resampling using pixel area relation. It may be a preferred
%                  method for image decimation, as it gives moire’-free results.
%                  But when the image is zoomed, it is similar to the 'Nearest'
%                  method.
%      'Cubic':    a bicubic interpolation over 4x4 pixel neighborhood
%      'Lanczos4': a Lanczos interpolation over 8x8 pixel neighborhood
%
% The function resize resizes the image src down to or up to the specified size.
%
% To shrink an image, it will generally look best with 'Area' interpolation,
% whereas to enlarge an image, it will generally look best with 'Cubic' (slow)
% or 'Linear' (faster but still looks OK).
%
% See also cv.warpAffine cv.warpPerspective
%
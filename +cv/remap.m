%REMAP  Applies a generic geometrical transformation to an image
%
%    dst = cv.remap(src, X, Y)
%    dst = cv.remap(src, XY)
%    dst = cv.remap(src, map1, map2)
%    dst = cv.remap(src, X, Y, 'BorderType', borderType, ...)
%    dst = cv.remap(src, XY, 'BorderType', borderType, ...)
%    dst = cv.remap(src, map1, map2, 'BorderType', borderType, ...)
%
% ## Input
% * __src__ Source image.
% * __X__ x values of the transformation
% * __Y__ y values of the transformation
% * __XY__ (x,y) values of the transformation
% * __map1__ The first map created by cv.convertMaps, int16 type
% * __map2__ The second map created by cv.convertMaps, uint16 type
%
% ## Output
% * __dst__ Destination image. It has the same size as X (or XY) and the same
%         type as src.
%
% ## Options
% * __BorderType__ Pixel extrapolation method. When 'Transparent' , it means
%                  that the pixels in the destination image that corresponds to
%                  the outliers in the source image are not modified by the
%                  function. default: 'Constant'
% * __BorderValue__ Value used in case of a constant border. default: 0
% * __Interpolation__ interpolation method. default: 'Linear'
% * __Nearest__ a nearest-neighbor interpolation
% * __Linear__ a bilinear interpolation (used by default)
% * __Cubic__ a bicubic interpolation over 4x4 pixel neighborhood
% * __Lanczos4__ a Lanczos interpolation over 8x8 pixel neighborhood
%
% The function remap transforms the source image using the specified map:
%
%     dst(x,y) = src(X(x,y), Y(x,y))
%
% where values of pixels with non-integer coordinates are computed using one of
% available interpolation methods.
%

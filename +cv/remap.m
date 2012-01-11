%REMAP  Applies a generic geometrical transformation to an image
%
%    dst = remap(src, X, Y)
%    dst = remap(src, XY)
%    dst = remap(src, map1, map2)
%    dst = remap(src, X, Y, 'BorderType', borderType, ...)
%    dst = remap(src, XY, 'BorderType', borderType, ...)
%    dst = remap(src, map1, map2, 'BorderType', borderType, ...)
%
%  Input:
%    src: Source image.
%      X: x values of the transformation
%      Y: y values of the transformation
%     XY: (x,y) values of the transformation
%   map1: The first map created by cv.convertMaps, int16 type
%   map2: The second map created by cv.convertMaps, uint16 type
%  Output:
%    dst: Destination image. It has the same size as X (or XY) and the same
%         type as src.
%  Options:
%    'BorderType': Pixel extrapolation method. When 'Transparent' , it means
%                  that the pixels in the destination image that corresponds to
%                  the “outliers” in the source image are not modified by the
%                  function. default: 'Constant'
%    'BorderValue': Value used in case of a constant border. default: 0
%    'Interpolation': interpolation method. default: 'Linear'
%      'Nearest':  a nearest-neighbor interpolation
%      'Linear':   a bilinear interpolation (used by default)
%      'Cubic':    a bicubic interpolation over 4x4 pixel neighborhood
%      'Lanczos4': a Lanczos interpolation over 8x8 pixel neighborhood
%
% The function remap transforms the source image using the specified map:
%
%     dst(x,y) = src(X(x,y), Y(x,y))
%
% where values of pixels with non-integer coordinates are computed using one of
% available interpolation methods.
%
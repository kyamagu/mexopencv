%WARPPERSPECTIVE  Applies a perspective transformation to an image
%
%    dst = warpPerspective(src, M)
%    dst = warpPerspective(src, M, 'DSize', dsize, ...)
%
%  Input:
%    src: Source image.
%    M: 3 x 3 transformation matrix.
%  Output:
%    dst: Destination image that has the size dsize and the same type as src.
%  Options:
%    'DSize': Size of the destination image
%    'Interpolation': interpolation method. default: 'Linear'
%    'WarpInverse': Logical flag to apply inverse affine transform, meaning
%                   that M is the inverse transformation (dst -> src)
%    'BorderType': Pixel extrapolation method. When 'Transparent', it means
%                  that the pixels in the destination image corresponding to
%                  the “outliers” in the source image are not modified by the
%                  function. default: 'Constant'
%    'BorderValue': Value used in case of a constant border. default: 0
%
% The function warpPerspective transforms the source image using the specified
% matrix:
%
%     dst(x,y) = src(M_11*x+M_12*y+M_13 / M_31*x+M_32*y+M_33,
%                    M_21*x+M_22*y+M_23 / M_31*x+M_32*y+M_33)
%
% when the 'WarpInverse' option is true. Otherwise, the transformation is first
% inverted with cv.invert and then put in the formula above instead of M.
%
% See also cv.warpAffine cv.resize cv.getRectSubPix
%
%WARPAFFINE  Applies an affine transformation to an image
%
%    dst = cv.warpAffine(src, M)
%    dst = cv.warpAffine(src, M, 'DSize', dsize, ...)
%
% ## Input
% * __src__ Source image.
% * __M__ 2 x 3 transformation matrix.
%
% ## Output
% * __dst__ Destination image that has the size dsize and the same type as src.
%
% ## Options
% * __DSize__ Size of the destination image
% * __Interpolation__ interpolation method. default: 'Linear'
% * __WarpInverse__ Logical flag to apply inverse affine transform, meaning
%     that M is the inverse transformation (dst -> src)
% * __BorderType__ Pixel extrapolation method. When 'Transparent', it means
%     that the pixels in the destination image corresponding to
%     the outliers in the source image are not modified by the
%     function. default: 'Constant'
% * __BorderValue__ Value used in case of a constant border. default: 0
%
% The function warpAffine transforms the source image using the specified
% matrix
%
%     dst(x,y) = src(M_11*x+M_12*y+M_13, M_21*x+M_22*y+M_23)
%
% when the 'WarpInverse' option is true. Otherwise, the transformation is first
% inverted with cv.invertAffineTransform and then put in the formula above
% instead of M.
%
% See also cv.warpPerspective cv.resize cv.getRectSubPix
%

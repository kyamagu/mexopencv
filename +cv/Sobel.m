%SOBEL  Calculates the first, second, third, or mixed image derivatives using an extended Sobel operator
%
%    dst = cv.Sobel(src)
%    dst = cv.Sobel(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ input image.
%
% ## Output
% * __dst__ output image of the same size and the same number of channels as
%         `src`.
%
% ## Options
% * __KSize__ size of the extended Sobel kernel. Aperture size used to compute
%       the second-derivative filters. The size must be positive and odd; it
%       must be 1, 3, 5, or 7. default 3
% * __XOrder__ Order of the derivative x. default 1
% * __YOrder__ Order of the derivative y. default 1
% * __Scale__ Optional scale factor for the computed derivative values. By
%       default, no scaling is applied (see cv.getDerivKernels for
%       details). default 1
% * __Delta__ Optional delta value that is added to the results prior to
%       storing them in `dst`. default 0
% * __BorderType__ Pixel extrapolation method. default 'Default'
% * __DDepth__ output image depth, see combinations below; in the case of
%       8-bit input images it will result in truncated derivatives.
%       When `DDepth=-1` (default), the output image will have the same depth
%       as the source.
%       * SDepth = 'uint8'           --> DDepth = -1, 'int16', 'single', 'double'
%       * SDepth = 'uint16', 'int16' --> DDepth = -1, 'single', 'double'
%       * SDepth = 'single'          --> DDepth = -1, 'single', 'double'
%       * SDepth = 'double'          --> DDepth = -1, 'double'
%
% In all cases except one, the `KSize x KSize` separable kernel is used to
% calculate the derivative. When `KSize=1`, the `3x1` or `1x3` kernel is used
% (that is, no Gaussian smoothing is done). `KSize=1` can only be used for the
% first or the second x- or y- derivatives.
%
% There is also the special value `KSize=-1` or `KSize='Scharr'` that
% corresponds to the `3x3` Scharr filter that may give more accurate results
% than the `3x3` Sobel. The Scharr aperture is:
%
%    [-3 0 3; -10 0 10; -3 0 3]
%
% for the x-derivative, or transposed for the y-derivative.
%
% The function calculates an image derivative by convolving the image with the
% appropriate kernel:
%
%                partial^(XOrder+YOrder) src
%    dst = ---------------------------------------
%           partial x^(XOrder) partial y^(YOrder)
%
% The Sobel operators combine Gaussian smoothing and differentiation, so the
% result is more or less resistant to the noise. Most often, the function is
% called with (`XOrder = 1`, `YOrder = 0`, `KSize = 3`) or (`XOrder = 0`,
% `YOrder = 1`, `KSize = 3`) to calculate the first x- or y- image derivative.
% The first case corresponds to a kernel of:
%
%    [-1 0 1; -2 0 2; -1 0 1]
%
% The second case corresponds to a kernel of:
%
%    [-1 -2 -1; 0 0 0; 1 2 1]
%
% See also: cv.Scharr, cv.Laplacian, cv.sepFilter2D, cv.filter2D,
%    cv.GaussianBlur, cv.cartToPolar, edge
%

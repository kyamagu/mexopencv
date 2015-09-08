%LAPLACIAN  Calculates the Laplacian of an image
%
%    dst = cv.Laplacian(src)
%    dst = cv.Laplacian(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Source image.
%
% ## Output
% * __dst__ Destination image of the same size and the same number of channels
%       as `src`.
%
% ## Options
% * __DDepth__ Desired depth of the destination image. default -1, which uses
%       the same type as the input `src`.
% * __KSize__ Aperture size used to compute the second-derivative filters. See
%       getDerivKernels for details. The size must be positive and odd.
%       default 1
% * __Scale__ Optional scale factor for the computed Laplacian values. By
%       default, no scaling is applied. See cv.getDerivKernels for details.
%       default 1
% * __Delta__ Optional delta value that is added to the results prior to
%       storing them in `dst`. default 0
% * __BorderType__ Pixel extrapolation method, see cv.copyMakeBorder.
%       Default 'Default'
%
% The function calculates the Laplacian of the source image by adding up the
% second x and y derivatives calculated using the Sobel operator:
%
%    dst = \Delta src = d^2(src)/dx^2 + d^2(src)/dy^2
%
% This is done when `KSize > 1`. When `KSize = 1`, the Laplacian is computed
% by filtering the image with the following 3x3 aperture:
%
%    [0, 1, 0; 1,-4, 1; 0, 1, 0]
%
% See also: cv.Sobel, cv.Scharr
%

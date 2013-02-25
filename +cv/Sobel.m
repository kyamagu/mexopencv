%SOBEL  Calculates the first, second, third, or mixed image derivatives using an extended Sobel operator
%
%    dst = cv.Sobel(src)
%    dst = cv.Sobel(src, 'KSize', 5, ...)
%
% ## Input
% * __src__ Source image.
%
% ## Output
% * __dst__ Destination image of the same size and the same number of channels as
%         src.
%
% ## Options
% * __KSize__ Aperture size used to compute the second-derivative filters. The
%             size must be positive and odd.
% * __XOrder__ Order of the derivative x.
% * __YOrder__ Order of the derivative y.
% * __Scale__ Optional scale factor for the computed Laplacian values. By
%             default, no scaling is applied.
% * __Delta__ Optional delta value that is added to the results prior to
%             storing them in dst .
% * __BorderType__ Pixel extrapolation method.
%
% In all cases except one, the KSize x KSize separable kernel is used to
% calculate the derivative. When KSize=1, the 3 x 1 or 1 x 3 kernel is used
% (that is, no Gaussian smoothing is done). ksize = 1 can only be used for the
% first or the second x- or y- derivatives.
%
% The function calculates an image derivative by convolving the image with the
% appropriate kernel. The Sobel operators combine Gaussian smoothing and
% differentiation, so the result is more or less resistant to the noise. Most
% often, the function is called with ( xorder = 1, yorder = 0, ksize = 3) or
% ( xorder = 0, yorder = 1, ksize = 3) to calculate the first x- or y- image
% derivative.
%

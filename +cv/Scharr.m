%SCHARR  Calculates the first x- or y- image derivative using Scharr operator
%
%    dst = cv.Scharr(src)
%    dst = cv.Scharr(src, 'KSize', 5, ...)
%
%  Input:
%    src: Source image.
%  Output:
%    dst: Destination image of the same size and the same number of channels as
%         src.
%  Options:
%    'XOrder': Order of the derivative x.
%    'YOrder': Order of the derivative y.
%	 'Scale': Optional scale factor for the computed Laplacian values. By
%             default, no scaling is applied.
%	 'Delta': Optional delta value that is added to the results prior to
%             storing them in dst .
%	 'BorderType': Pixel extrapolation method.
%
% The function computes the first x- or y- spatial image derivative using the
% Scharr operator.
%
% See also cv.Sobel
%
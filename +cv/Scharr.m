%SCHARR  Calculates the first x- or y- image derivative using Scharr operator
%
%    dst = cv.Scharr(src)
%    dst = cv.Scharr(src, 'KSize', 5, ...)
%
% ## Input
% * __src__ Source image.
%
% ## Output
% * __dst__ Destination image of the same size and the same number of channels as
%         src.
%
% ## Options
% * __XOrder__ Order of the derivative x.
% * __YOrder__ Order of the derivative y.
% * __Scale__ Optional scale factor for the computed Laplacian values. By
%             default, no scaling is applied.
% * __Delta__ Optional delta value that is added to the results prior to
%             storing them in dst .
% * __BorderType__ Pixel extrapolation method.
%
% The function computes the first x- or y- spatial image derivative using the
% Scharr operator.
%
% See also cv.Sobel
%

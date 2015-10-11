%SCHARR  Calculates the first x- or y- image derivative using Scharr operator
%
%    dst = cv.Scharr(src)
%    dst = cv.Scharr(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input image.
%
% ## Output
% * __dst__ output image of the same size and the same number of channels as
%       `src`.
%
% ## Options
% * __XOrder__ Order of the derivative x. default 1
% * __YOrder__ Order of the derivative y. default 0
% * __Scale__ Optional scale factor for the computed Laplacian values. By
%       default, no scaling is applied (see cv.getDerivKernels for details).
%       default 1
% * __Delta__ Optional delta value that is added to the results prior to
%       storing them in `dst`. default 0
% * __BorderType__ Pixel extrapolation method, see cv.copyMakeBorder.
%       Default 'Default'
% * __DDepth__ output image depth. default -1. When `DDepth=-1`, the output
%       image will have the same depth as the source. The following
%       combinations are supported:
%       * SDepth = 'uint8'           --> DDepth = -1, 'int16', 'single', 'double'
%       * SDepth = 'uint16', 'int16' --> DDepth = -1, 'single', 'double'
%       * SDepth = 'single'          --> DDepth = -1, 'single', 'double'
%       * SDepth = 'double'          --> DDepth = -1, 'double'
%
% The function computes the first x- or y- spatial image derivative using the
% Scharr operator.
%
% The call:
%
%    dst = cv.Scharr(src, 'DDepth',ddepth, 'XOrder',dx, 'YOrder',dy, ...
%        'Scale',scale, 'Delta',delta, 'BorderType',borderType)
%
% is equivalent to:
%
%    dst = cv.Sobel(src, 'DDepth',ddepth, 'XOrder',dx, 'YOrder',dy, ...
%        'KSize','Scharr', ...
%        'Scale',scale, 'Delta',delta, 'BorderType',borderType)
%
% See also: cv.Sobel, cv.cartToPolar
%

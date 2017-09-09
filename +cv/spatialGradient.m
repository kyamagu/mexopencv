%SPATIALGRADIENT  Calculates the first order image derivative in both x and y using a Sobel operator
%
%     [dx, dy] = cv.spatialGradient(src)
%     [...] = cv.spatialGradient(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ input image, 8-bit single-channel.
%
% ## Output
% * __dx__ output `int16` image with first-order derivative in x.
% * __dy__ output `int16` image with first-order derivative in y.
%
% ## Options
% * __KSize__ size of Sobel kernel. It must be 3 in the current implementation.
%   default 3
% * __BorderType__ Pixel extrapolation method, see cv.copyMakeBorder. Only
%   'Default', 'Reflect101', and 'Replicate' are supported. default 'Default'
%
% Equivalent to calling:
%
%     dx = cv.Sobel(src, 'DDepth','int16', 'XOrder',1, 'YOrder',0, 'KSize',3);
%     dy = cv.Sobel(src, 'DDepth','int16', 'XOrder',0, 'YOrder',1, 'KSize',3);
%
% See also: cv.Sobel, imgradientxy, imgradient
%

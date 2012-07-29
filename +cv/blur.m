%BLUR  Smoothes an image using the normalized box filter
%
%    dst = cv.blur(src)
%    dst = cv.blur(src, 'KSize', [5,5], ...)
%
% ## Input
% * __src__ Source image.
%
% ## Output
% * __dst__ Destination image of the same size and type as src.
%
% ## Options
% * __KSize__ Smoothing kernel size. default [5,5]
% * __Anchor__ Anchor point. The default value Point(-1,-1) means that
%         the anchor is at the kernel center.
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%         image. default 'Default'
%
% The function smoothes an image using the kernel:
% 
%    K = ones(KSize) / prod(KSize)
%
% See also cv.medianBlur cv.GaussianBlur
%

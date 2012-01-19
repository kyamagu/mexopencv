%BLUR  Smoothes an image using the normalized box filter
%
%   dst = cv.blur(src)
%   dst = cv.blur(src, 'KSize', [5,5], ...)
%
% The function smoothes an image using the kernel:
% 
%   K = ones(KSize) / prod(KSize)
%
% Input:
%     src: Source image.
% Output:
%     dst: Destination image of the same size and type as src.
% Options:
%     'KSize': Smoothing kernel size. default [5,5]
%     'Anchor': Anchor point. The default value Point(-1,-1) means that
%               the anchor is at the kernel center.
%     'BorderType': Border mode used to extrapolate pixels outside of the
%                   image. default 'Default'
%
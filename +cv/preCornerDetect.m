%PRECORNERDETECT  Calculates a feature map for corner detection
%
%   dst = cv.preCornerDetect(src)
%   dst = cv.preCornerDetect(src, 'OptionName', optionValue, ...)
%
% Input:
%     src: Source single-channel 8-bit of floating-point image.
% Output:
%     dst: Output image that has the single type and the same size as src .
% Options:
%     'ApertureSize': Aperture parameter for the Sobel() operator. default 3.
%     'BorderType': Border mode used to extrapolate pixels outside of the
%                   image. default 'Default'
%
% The function calculates the complex spatial derivative-based function of the
% source image.
%
% The corners can be found as local maximums of the functions.
%
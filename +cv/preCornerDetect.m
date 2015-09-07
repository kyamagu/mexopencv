%PRECORNERDETECT  Calculates a feature map for corner detection
%
%    dst = cv.preCornerDetect(src)
%    dst = cv.preCornerDetect(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Source single-channel 8-bit of floating-point image.
%
% ## Output
% * __dst__ Output image that has the `single` type and the same size as `src`.
%
% ## Options
% * __KSize__ Aperture size of the cv.Sobel operator. default 3.
% * __BorderType__ Pixel extrapolation method. default 'Default'
%
% The function calculates the complex spatial derivative-based function of the
% source image.
%
%    dst = (Dx*src)^2*Dyy*src + (Dy*src)^2*Dxx*src - 2*Dx*src*Dy*src*Dxy*src
%
% where `Dx`, `Dy` are the first image derivatives, `Dxx`, `Dyy` are the
% second image derivatives, and `Dxy` is the mixed derivative.
%
% The corners can be found as local maximums of the functions, as shown below:
%
%    corners = cv.preCornerDetect(image, 'KSize',3);
%
%    % dilation with 3x3 rectangular structuring element
%    dilated_corners = cv.dilate(corners);
%    corner_mask = (corners == dilated_corners);
%
% See also: cv.cornerMinEigenVal
%

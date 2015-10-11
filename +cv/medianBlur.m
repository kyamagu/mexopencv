%MEDIANBLUR  Blurs an image using the median filter
%
%    dst = cv.medianBlur(src)
%    dst = cv.medianBlur(src, 'KSize',ksize)
%
% ## Input
% * __src__ Input 1-, 3-, or 4-channel image. When `KSize` is 3 or 5, the
%       image type should be `uint8`, `uint16`, or `single`. For larger
%       aperture sizes, it can only be `uint8`.
%
% ## Output
% * __dst__ Destination array of the same size and type as `src`.
%
% ## Options
% * __KSize__ Aperture linear size. It must be odd and greater than 1, for
%       example 3, 5, 7 ... default 5
%
% The function smoothes an image using the median filter with the
% `KSize x KSize` aperture. Each channel of a multi-channel image is
% processed independently.
%
% See also: cv.bilateralFilter, cv.blur, cv.boxFilter, cv.GaussianBlur,
% medfilt2
%

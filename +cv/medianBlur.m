%MEDIANBLUR  Smoothes an image using the median filter
%
%   dst = cv.medianBlur(src)
%   dst = cv.medianBlur(src, 'KSize', [5,5])
%
% The function smoothes an image using the median filter with the aperture.
% Each channel of a multi-channel image is processed independently.
%
% Input:
%     src: Source 1-, 3-, or 4-channel image. When ksize is 3 or 5, the image
%          depth should be CV_8U, CV_16U, or CV_32F. For larger aperture sizes,
%          it can only be CV_8U.
% Output:
%     dst: Destination array of the same size and type as src.
% Options:
%     'KSize': Aperture linear size. It must be odd and greater than 1, for
%              example: 3, 5, 7 ...
%
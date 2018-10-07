%THRESHOLD  Applies a fixed-level threshold to each array element
%
%     dst = cv.threshold(src, thresh)
%     dst = cv.threshold(src, thresh, 'OptionName',optionValue, ...)
%     [dst, thresh] = cv.threshold(src, 'auto', ...)
%
% ## Input
% * __src__ Input array (single or multiple channel, 8-bit, 16-bit, or
%   floating-point).
% * __thresh__ Threshold value. Scalar numeric value or one of the strings:
%   * __Otsu__ use Otsu algorithm to choose the optimal threshold value
%   * __Triangle__ use Triangle algorithm to choose the optimal threshold value
%
% ## Output
% * __dst__ Output array of the same size and type as `src`.
% * __thresh__ the computed threshold value if Otsu's or Triangle methods are
%   used.
%
% ## Options
% * __MaxValue__ Maximum value to use with the 'Binary' and 'BinaryInv'
%   thresholding types. default 255
% * __Type__ Thresholding type, default 'Binary'. One of:
%   * __Binary__    `dst(x,y) = (src(x,y) > thresh) ? maxVal : 0`
%   * __BinaryInv__ `dst(x,y) = (src(x,y) > thresh) ? 0 : maxVal`
%   * __Trunc__     `dst(x,y) = (src(x,y) > thresh) ? thresh : src(x,y)`
%   * __ToZero__    `dst(x,y) = (src(x,y) > thresh) ? src(x,y) : 0`
%   * __ToZeroInv__ `dst(x,y) = (src(x,y) > thresh) ? 0 : src(x,y)`
%
% The function applies fixed-level thresholding to a multiple-channel array.
% The function is typically used to get a bi-level (binary) image out of a
% grayscale image (cv.compare could be also used for this purpose) or for
% removing a noise, that is, filtering out pixels with too small or too large
% values. There are several types of thresholding supported by the function.
% They are determined by `Type` parameter.
%
% When `thresh` is set 'Otsu' or 'Triangle', the function determines the
% optimal threshold value using the Otsu's or Triangle algorithm.
%
% Note: Currently, the Otsu's and Triangle methods are implemented only for
% 8-bit single-channel images.
%
% See also: cv.adaptiveThreshold, cv.findContours, cv.compare,
%  im2bw, graythresh, multithresh, imbinarize, otsuthresh, grayslice
%

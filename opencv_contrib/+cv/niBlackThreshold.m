%NIBLACKTHRESHOLD  Applies Niblack thresholding to input image
%
%    dst = cv.niBlackThreshold(src, delta)
%    dst = cv.niBlackThreshold(src, delta, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source 8-bit single-channel image.
% * __delta__ Constant multiplied with the standard deviation and subtracted
%       from the mean (`mean + k * std`). Normally, it is taken to be a real
%       number between 0 and 1.
%
% ## Output
% * __dst__ Destination image of the same size and the same type as `src`.
%
% ## Options
% * __MaxValue__ Non-zero value assigned to the pixels for which the condition
%       is satisfied, used with the `Binary` and `BinaryInv` thresholding
%       types. default 255
% * __Type__ Thresholding type, default 'Binary'. One of:
%       * __Binary__    `dst(x,y) = (src(x,y) > thresh) ? maxValue : 0`
%       * __BinaryInv__ `dst(x,y) = (src(x,y) > thresh) ? 0 : maxValue`
% * __BlockSize__ Size of a pixel neighborhood that is used to calculate a
%       threshold value for the pixel: 3, 5, 7, and so on. default 5
%
% The function transforms a grayscale image to a binary image according to the
% formulae:
%
% * __Binary__
%
%                   | maxValue, if src(x,y) > T(x,y)
%        dst(x,y) = |
%                   | 0, otherwise
%
% * __BinaryInv__
%
%                   | 0, if src(x,y) > T(x,y)
%        dst(x,y) = |
%                   | maxValue, otherwise
%
% where `T(x,y)` is a threshold calculated individually for each pixel.
%
% The threshold value `T(x,y)` is the mean minus `delta` times standard
% deviation of `BlockSize x BlockSize` neighborhood of `(x,y)`.
%
% See also: cv.threshold, cv.adaptiveThreshold
%

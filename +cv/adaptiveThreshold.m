%ADAPTIVETHRESHOLD  Applies an adaptive threshold to an array
%
%    dst = cv.adaptiveThreshold(src, maxValue)
%    dst = cv.adaptiveThreshold(src, maxValue, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source 8-bit single-channel `uint8` image.
% * __maxValue__ Non-zero value assigned to the pixels for which the condition
%        is satisfied. See the details below.
%
% ## Output
% * __dst__ Destination image of the same size and the same type as `src`.
%
% ## Options
% * __AdaptiveMethod__ Adaptive thresholding algorithm to use, default 'Mean'.
%       One of:
%       * __Mean__ the threshold value `T(x,y)` is a mean of the
%             `BlockSize x BlockSize` neighborhood of `(x,y)` minus `C`
%       * __Gaussian__ the threshold value `T(x,y)` is a weighted sum
%             (cross-correlation with a Gaussian window) of the
%             `BlockSize x BlockSize` neighborhood of `(x,y)` minus `C`.
%             The default sigma (standard deviation) is used for the specified
%             `BlockSize`. See cv.getGaussianKernel
% * __ThresholdType__ Thresholding type, default 'Binary'. One of:
%       * __Binary__    `dst(x,y) = (src(x,y) > thresh) ? maxValue : 0`
%       * __BinaryInv__ `dst(x,y) = (src(x,y) > thresh) ? 0 : maxValue`
% * __BlockSize__ Size of a pixel neighborhood that is used to calculate a
%        threshold value for the pixel: 3, 5, 7, and so on. Default 3
% * __C__ Constant subtracted from the mean or weighted mean. Normally, it
%        is positive but may be zero or negative as well. Default 5
%
% The function transforms a grayscale image to a binary image according to
% the formulae:
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
% where `T(x,y)` is a threshold calculated individually for each pixel (see
% `AdaptiveMethod` parameter).
%
% See also: cv.threshold, cv.blur, cv.GaussianBlur
%

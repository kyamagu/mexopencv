%ADAPTIVETHRESHOLD  Applies an adaptive threshold to an array
%
%    dst = cv.adaptiveThreshold(src, maxVal)
%    dst = cv.adaptiveThreshold(src, maxVal, 'AdaptiveMethod', 'Mean', ...)
%
% ## Input
% * __src__ Source 8-bit single-channel image.
% * __maxVal__ Non-zero value assigned to the pixels for which the condition
%        is satisfied.
%
% ## Output
% * __dst__ Destination image of the same size and the same type as src.
%
% ## Options
% * __AdaptiveMethod__ Adaptive thresholding algorithm to use, either
%        'Mean' or 'Gaussian'.
% * __ThresholdType__ Thresholding type that must be either 'Binary' or
%        'BinaryInv'.
% * __BlockSize__ Size of a pixel neighborhood that is used to calculate a
%        threshold value for the pixel: 3, 5, 7, and so on.
% * __C__ Constant subtracted from the mean or weighted mean. Normally, it
%        is positive but may be zero or negative as well.
%

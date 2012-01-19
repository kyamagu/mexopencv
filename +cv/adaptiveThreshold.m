%ADAPTIVETHRESHOLD  Applies an adaptive threshold to an array
%
%    dst = cv.adaptiveThreshold(src, maxVal)
%    dst = cv.adaptiveThreshold(src, maxVal, 'AdaptiveMethod', 'Mean', ...)
%
%  Input:
%    src: Source 8-bit single-channel image.
%    maxVal: Non-zero value assigned to the pixels for which the condition is
%            satisfied.
%  Output:
%    dst: Destination image of the same size and the same type as src.
%  Options:
%    'AdaptiveMethod': Adaptive thresholding algorithm to use, either
%                      'Mean' or 'Gaussian'.
%    'ThresholdType': Thresholding type that must be either 'Binary' or
%                    'BinaryInv'.
%    'BlockSize': Size of a pixel neighborhood that is used to calculate a
%                 threshold value for the pixel: 3, 5, 7, and so on.
%    'C': Constant subtracted from the mean or weighted mean. Normally, it is
%         positive but may be zero or negative as well.
%
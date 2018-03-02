%CLAHE  Contrast Limited Adaptive Histogram Equalization
%
%     dst = cv.CLAHE(src)
%     dst = cv.CLAHE(src, 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit or 16-bit single-channel image.
%
% ## Output
% * __dst__ output image
%
% ## Options
% * __ClipLimit__ Threshold for contrast limiting. default 40.0
% * __TileGridSize__ Size of grid for histogram equalization. Input image will
%   be divided into equally sized rectangular tiles. `TileGridSize` defines
%   the number of tiles in row and column. default [8,8]
%
% Equalizes the histogram of a grayscale image using Contrast Limited Adaptive
% Histogram Equalization.
%
% See also: adapthisteq, cv.equalizeHist
%

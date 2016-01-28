%AUTOWBGRAYWORLD  Implements a simple grayworld white balance algorithm
%
%    dst = cv.autowbGrayworld(src)
%    dst = cv.autowbGrayworld(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input array. Currently only works on color images of type `uint8`
%       (3-channels).
%
% ## Output
% * __dst__ Output array of the same size and type as `src`.
%
% ## Options
% * __Thresh__ Maximum saturation for a pixel to be included in the gray-world
%       assumption. default 0.5
%
% The function cv.autowbGrayworld scales the values of pixels based on a
% gray-world assumption which states that the average of all channels
% should result in a gray image.
%
% This function adds a modification which thresholds pixels based on their
% saturation value and only uses pixels below the provided threshold in
% finding average pixel values.
%
% Saturation is calculated using the following for a 3-channel RGB image per
% pixel `I` and is in the range `[0,1]`:
%
%     Saturation[I] = (max(R,G,B) - min(R,G,B)) / max(R,G,B)
%
% A threshold of 1 means that all pixels are used to white-balance, while a
% threshold of 0 means no pixels are used. Lower thresholds are useful in
% white-balancing saturated images.
%
% See also: cv.balanceWhite
%

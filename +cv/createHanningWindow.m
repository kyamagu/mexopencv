%CREATEHANNINGWINDOW  Computes a Hanning window coefficients in two dimensions
%
%     dst = cv.createHanningWindow(winSize)
%     dst = cv.createHanningWindow(winSize, 'Type',type)
%
% ## Input
% * __winSize__ The window size specifications `[w,h]` (both width and height
%   must be > 1).
%
% ## Output
% * __dst__ Destination array containing Hann coefficients.
%
% ## Options
% * __Type__ Created array type. Either `single` or `double` (default).
%
% This function computes a Hanning window coefficients in two dimensions.
%
% See [Hann function](https://en.wikipedia.org/wiki/Hann_function) and
% [Window function](https://en.wikipedia.org/wiki/Window_function) for more
% information.
%
% See also: hann, hanning
%

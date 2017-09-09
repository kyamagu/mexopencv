%CANNY2  Finds edges in an image using the Canny algorithm with custom image gradient
%
%     edges = cv.Canny2(dx, dy, thresh)
%     edges = cv.Canny2(dx, dy, thresh, 'OptionName', optionValue, ...)
%
% ## Input
% * __dx__ 16-bit x derivative of input image (1 or 3 channels of type `int16`).
% * __dy__ 16-bit y derivative of input image (same size and type as `dx`).
% * __thresh__ Threshold for the hysteresis procedure. Scalar or 2-element
%   vector `[low_thresh,high_thresh]`.
%
% ## Output
% * __edges__ Output edge map; single channels 8-bit image, which has the same
%   size as the input image.
%
% ## Options
% * __L2Gradient__ Flag indicating whether a more accurate L2 norm
%   `sqrt((dI/dx)^2 + (dI/dy)^2)` should be used to compute the image gradient
%   magnitude (`L2gradient=true`), or whether the default L1 norm
%   `abs(dI/dx) + abs(dI/dy)` is enough (`L2gradient=false`). Default false
%
% See also: cv.Canny, cv.Sobel, cv.Scharr
%

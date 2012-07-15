%THRESHOLD  Applies a fixed-level threshold to each array element
%
%    dst = cv.threshold(src, thresh)
%    dst = cv.threshold(src, thresh, 'Method', 'Binary', ...)
%    [dst, thresh] = cv.threshold(src, 'auto', ...)
%
% ## Input
% * __src__ Source array (single-channel, 8-bit of 32-bit floating point).
% * __thresh__ Threshold value. Scalar numeric value or 'auto'.
%
% ## Output
% * __dst__ Destination array of the same size and type as src.
% * __thresh__ Threshold value used.
%
% ## Options
% * __Method__ Thresholding type (see the details below). default 'Trunc'
% * __MaxValue__ Maximum value to use with the 'Binary' and 'BinaryInv' methods.
%
% The function applies fixed-level thresholding to a single-channel array. The
% function is typically used to get a bi-level (binary) image out of a
% grayscale image ( compare() could be also used for this purpose) or for
% removing a noise, that is, filtering out pixels with too small or too large
% values. There are several types of thresholding supported by the function.
% They are determined by thresholdType:
%
% * __Binary__ dst(x,y) = (src(x,y)>thresh) ? maxVal : 0
% * __BinaryInv__ dst(x,y) = (src(x,y)>thresh) ? 0 : maxVal
% * __Trunc__ dst(x,y) = (src(x,y)>thresh) ? threshold : src(x,y)
% * __ToZero__ dst(x,y) = (src(x,y)>thresh) ? src(x,y) : 0
% * __ToZeroInv__ dst(x,y) = (src(x,y)>thresh) ? 0 : src(x,y)
%
% When thresh is set 'auto', the function determines the optimal threshold
% value using the Otsu's algorithm and uses it instead of the specified
% thresh. The function returns the computed threshold value. Currently, the
% Otsu's method is implemented only for 8-bit images.
%

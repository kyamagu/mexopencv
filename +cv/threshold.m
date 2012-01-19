%THRESHOLD  Applies a fixed-level threshold to each array element
%
%    dst = cv.threshold(src, thresh)
%    dst = cv.threshold(src, thresh, 'Method', 'Binary', ...)
%    [dst, thresh] = cv.threshold(src, 'auto', ...)
%
%  Input:
%    src: Source array (single-channel, 8-bit of 32-bit floating point).
%    thresh: Threshold value. Scalar numeric value or 'auto'.
%  Output:
%    dst: Destination array of the same size and type as src.
%    thresh: Threshold value used.
%  Options:
%    'Method': Thresholding type (see the details below). default 'Trunc'
%	 'MaxVal': Maximum value to use with the 'Binary' and 'BinaryInv' methods.
%
% The function applies fixed-level thresholding to a single-channel array. The
% function is typically used to get a bi-level (binary) image out of a
% grayscale image ( compare() could be also used for this purpose) or for
% removing a noise, that is, filtering out pixels with too small or too large
% values. There are several types of thresholding supported by the function.
% They are determined by thresholdType:
%
%   'Binary':     dst(x,y) = (src(x,y)>thresh) ? maxVal : 0
%   'BinaryInv':  dst(x,y) = (src(x,y)>thresh) ? 0 : maxVal
%   'Trunc':      dst(x,y) = (src(x,y)>thresh) ? threshold : src(x,y)
%   'ToZero':     dst(x,y) = (src(x,y)>thresh) ? src(x,y) : 0
%   'ToZeroInv':  dst(x,y) = (src(x,y)>thresh) ? 0 : src(x,y)
%
% When thresh is set 'auto', the function determines the optimal threshold
% value using the Otsu’s algorithm and uses it instead of the specified thresh.
% The function returns the computed threshold value. Currently, the Otsu’s
% method is implemented only for 8-bit images.
%
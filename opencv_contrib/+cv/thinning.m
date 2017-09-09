%THINNING  Applies a binary blob thinning operation, to achieve a skeletization of the input image
%
%     dst = cv.thinning(src)
%     dst = cv.thinning(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source 8-bit single-channel image, containing binary blobs, with
%   blobs having 255 pixel values.
%
% ## Output
% * __dst__ Destination image of the same size and the same type as `src`.
%
% ## Options
% * __ThinningType__ Which thinning algorithm should be used. One of:
%   * __ZhangSuen__ Thinning technique of Zhang-Suen (default).
%   * __GuoHall__ Thinning technique of Guo-Hall.
%
% The function transforms a binary blob image into a skeletized form using the
% technique of Zhang-Suen.
%
% See also: cv.threshold, bwmorph
%

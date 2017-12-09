%DRAWDETECTEDDIAMONDS  Draw a set of detected ChArUco Diamond markers
%
%     img = cv.drawDetectedDiamonds(img, diamondCorners)
%     img = cv.drawDetectedDiamonds(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image. It must have 1 or 3 channels. In the output, the
%   number of channels is not altered.
% * __diamondCorners__ positions of diamond corners in the same format
%   returned by cv.detectCharucoDiamond. (e.g `{{[x y],..}, ..}`). The order
%   of the corners should be clockwise.
%
% ## Output
% * __img__ output image.
%
% ## Options
% * __IDs__ vector of identifiers for diamonds in `diamondCorners` (0-based),
%   in the same format returned by cv.detectCharucoDiamond (e.g. cell array of
%   4-integer vectors). Optional, if not provided, ids are not painted.
% * __BorderColor__ color of marker borders. Rest of colors (text color and
%   first corner color) are calculated based on this one. Default [0,0,255].
%
% Given an array of detected diamonds, this functions draws them in the image.
% The marker borders are painted and the markers identifiers if provided.
% Useful for debugging purposes.
%
% See also: cv.detectCharucoDiamond, cv.detectMarkers,
%  cv.line, cv.rectangle, cv.putText
%

%DRAWDETECTEDMARKERS  Draw detected markers in image
%
%     img = cv.drawDetectedMarkers(img, corners)
%     img = cv.drawDetectedMarkers(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image. It must have 1 or 3 channels. In the output, the
%   number of channels is not altered.
% * __corners__ positions of marker corners on input image. (e.g
%   `{{[x,y],..}, ..}`). The order of the corners should be clockwise.
%
% ## Output
% * __img__ output image.
%
% ## Options
% * __IDs__ vector of identifiers for markers in `corners` (0-based).
%   Optional, if not provided, ids are not painted.
% * __BorderColor__ color of marker borders. Rest of colors (text color and
%   first corner color) are calculated based on this one to improve
%   visualization. default [0,255,0].
%
% Given an array of detected marker corners and its corresponding ids, this
% functions draws the markers in the image. The marker borders are painted
% and the markers identifiers if provided. Useful for debugging purposes.
%
% See also: cv.detectMarkers, cv.line, cv.rectangle, cv.putText
%

%DRAWMARKER  Draws a marker on a predefined position in an image
%
%     img = cv.drawMarker(img, pos)
%     img = cv.drawMarker(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Input image.
% * __pos__ The point where the crosshair is positioned `[x,y]`.
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __Color__ Line color. Default is a black color.
% * __MarkerType__ The specific type of marker you want to use. One of:
%   * __Cross__ (`+`) (default) A crosshair marker shape.
%   * __TiltedCross__ (`x`) A 45 degree tilted crosshair marker shape.
%   * __Star__ (`*`) A star marker shape, combination of cross and tilted
%     cross.
%   * __Diamond__ (`d`) A diamond marker shape.
%   * __Square__ (`s`) A square marker shape.
%   * __TriangleUp__ (`^`) An upwards pointing triangle marker shape.
%   * __TriangleDown__ (`v`) A downwards pointing triangle marker shape.
% * __MarkerSize__ The length of the marker axis. Default is 20 pixels.
% * __Thickness__ Line thickness. default 1
% * __LineType__ Type of the line. One of:
%   * __4__ 4-connected line
%   * __8__ 8-connected line (default)
%   * __AA__ anti-aliased line
%
% The function cv.drawMarker draws a marker on a given position in the image.
% For the moment several marker types are supported, see `MarkerType` for more
% information.
%
% See also: cv.line, cv.circle
%

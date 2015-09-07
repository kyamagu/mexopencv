%ARROWEDLINE  Draws an arrow segment pointing from the first point to the second one.
%
%    img = cv.arrowedLine(img, pt1, pt2)
%    [...] = cv.arrowedLine(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image where the arrow is drawn.
% * __pt1__ The point `[x,y]` the arrow starts from.
% * __pt2__ The point `[x,y]` the arrow points to.
%
% ## Output
% * __img__ Output image.
%
% ## Options
% * __Color__ Line color. default is a black color
% * __Thickness__ Line thickness. default 1.
% * __LineType__ Type of the line. One of 8,4,'AA' (Anti-aliased line).
%       default 8.
% * __Shift__ Number of fractional bits in the point coordinates. default 0.
% * __TipLength__ The length of the arrow tip in relation to the arrow length.
%       default 0.1
%
% The function cv.arrowedLine draws an arrow between `pt1` and `pt2` points
% in the image.
%
% See also: cv.line
%

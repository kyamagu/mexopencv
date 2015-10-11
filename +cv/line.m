%LINE  Draws a line segment connecting two points
%
%    img = cv.line(img, pt1, pt2)
%    [...] = cv.line(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __img__ Image.
% * __pt1__ First point of the line segment `[x1,y1]`.
% * __pt2__ Second point of the line segment `[x2,y2]`.
%
% ## Output
% * __img__ Output image, same size and type as input `img`.
%
% ## Options
% * __Color__ 3-element floating point vector specifying line color.
%       default zeros
% * __Thickness__ Line thickness. default 1.
% * __LineType__ Type of the line boundary. One of:
%       * 8: 8-connected line (default)
%       * 4: 4-connected line
%       * 'AA': anti-aliased line
% * __Shift__ Number of fractional bits in the point coordinates. default 0
%
% The function cv.line draws the line segment between `pt1` and `pt2` points
% in the image. The line is clipped by the image boundaries. For
% non-antialiased lines with integer coordinates, the 8-connected or
% 4-connected Bresenham algorithm is used. Thick lines are drawn with
% rounding endings. Antialiased lines are drawn using Gaussian filtering.
%
% See also: cv.circle, cv.ellipse, cv.rectangle, cv.polylines
%

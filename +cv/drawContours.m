%DRAWCONTOURS  Draws contours outlines or filled contours
%
%    im = cv.drawContours(im, contours)
%    im = cv.drawContours(im, contours, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Image on which to draw contours.
% * __contours__ All the input contours. Each contour is stored as a 2D point
%       vector (integer points). A cell array of cell arrays of the form:
%       `{{[x,y],[x,y],...}, ...}`, or a cell array of Nx2 matrices.
%
% ## Output
% * __im__ Destination image, same size and type as input `im`.
%
% ## Options
% * __ContourIdx__ Parameter indicating a contour to draw. A zero-based index
%       in the range `[0,length(contours)-1]`. If it is negative, all the
%       contours are drawn. default -1
% * __Color__ Color of the contours. default is white color.
% * __Thickness__ Thickness of lines the contours are drawn with. If it is
%       negative (for example, -1 or the string 'Filled'), the contour
%       interiors are drawn. default 1
% * __LineType__ Line connectivity. One of 4,8,'AA' (Anti-aliased line).
%       default 8
% * __Hierarchy__ Optional information about hierarchy. It is only needed if
%       you want to draw only some of the contours (see `MaxLevel`).
%       A cell array of 4-element vectors for each contour of the form
%       `{[next,prev,child,parent], ...}`, or a Nx4/Nx1x4/1xNx4 numeric
%       matrix of integers. default empty
% * __MaxLevel__ Maximal level for drawn contours. If it is 0, only the
%       specified contour is drawn. If it is 1, the function draws the
%       contour(s) and all the nested contours. If it is 2, the function draws
%       the contours, all the nested contours, all the nested-to-nested
%       contours, and so on. This parameter is only taken into account when
%       there is `Hierarchy` available. default `intmax('int32')`
% * __Offset__ Optional contour shift parameter. Shift all the drawn contours
%       by the specified `offset = (dx,dy)`. default [0,0]
%
% The function draws contour outlines in the image if `Thickness >= 0` or
% fills the area bounded by the contours if `Thickness < 0`.
%
% See also: cv.findContours, visboundaries, bwlabel
%

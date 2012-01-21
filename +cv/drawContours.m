%DRAWCONTOURS  Draws contours outlines or filled contours
%
%   im = cv.drawContours(im, contours)
%   im = cv.drawContours(im, contours, 'OptionName', optionValue, ...)
%
% Input:
%     im: Image to be drawn contours.
%     contours: All the input contours. Each contour is stored as a point vector.
% Output:
%     im: Destination image.
% Options:
%     'ContourIdx': Parameter indicating a contour to draw. If it is negative,
%         all the contours are drawn.
%     'Color': Color of the contours.
%     'Thickness': Thickness of lines the contours are drawn with. If it is
%         negative (for example, thickness=CV_FILLED ), the contour interiors
%         are drawn.
%     'LineType': Line connectivity.
%     'Hierarchy': Optional information about hierarchy. It is only needed if
%         you want to draw only some of the contours (see MaxLevel).
%     'MaxLevel': Maximal level for drawn contours. If it is 0, only the
%         specified contour is drawn. If it is 1, the function draws the
%         contour(s) and all the nested contours. If it is 2, the function draws
%         the contours, all the nested contours, all the nested-to-nested
%         contours, and so on. This parameter is only taken into account when
%         there is hierarchy available.
%     'Offset': Optional contour shift parameter. Shift all the drawn contours
%         by the specified offset (dx,dy).
%
% The function draws contour outlines in the image if thickness >= 0 or or fills
% the area bounded by the contours if thickness < 0.
%
% See also cv.findContours
%
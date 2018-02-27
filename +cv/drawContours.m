%DRAWCONTOURS  Draws contours outlines or filled contours
%
%     im = cv.drawContours(im, contours)
%     im = cv.drawContours(im, contours, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Image on which to draw contours.
% * __contours__ All the input contours. Each contour is stored as a 2D point
%   vector (integer points). A cell array of cell arrays of the form:
%   `{{[x,y],[x,y],...}, ...}`, or a cell array of Nx2 matrices.
%
% ## Output
% * __im__ Destination image, same size and type as input `im`.
%
% ## Options
% * __ContourIdx__ Parameter indicating a contour to draw. A zero-based index
%   in the range `[0,length(contours)-1]`. If it is negative, all the contours
%   are drawn. default -1
% * __Color__ Color of the contours. default is white color.
% * __Thickness__ Thickness of lines the contours are drawn with. If it is
%   negative (for example, -1 or the string 'Filled'), the contour interiors
%   are drawn. default 1
% * __LineType__ Line connectivity. One of:
%   * __4__ 4-connected line
%   * __8__ 8-connected line (default)
%   * __AA__ anti-aliased line
% * __Hierarchy__ Optional information about hierarchy. It is only needed if
%   you want to draw only some of the contours (see `MaxLevel`). A cell array
%   of 4-element vectors for each contour of the form
%   `{[next,prev,child,parent], ...}`, or a Nx4/Nx1x4/1xNx4 numeric matrix of
%   integers. default empty
% * __MaxLevel__ Maximal level for drawn contours. If it is 0, only the
%   specified contour is drawn. If it is 1, the function draws the contour(s)
%   and all the nested contours. If it is 2, the function draws the contours,
%   all the nested contours, all the nested-to-nested contours, and so on.
%   This parameter is only taken into account when there is `Hierarchy`
%   available. default `intmax('int32')`
% * __Offset__ Optional contour shift parameter. Shift all the drawn contours
%   by the specified `offset = (dx,dy)`. default [0,0]
%
% The function draws contour outlines in the image if `Thickness >= 0` or
% fills the area bounded by the contours if `Thickness < 0`.
%
% ## Example
% The example below shows how to retrieve connected components from a binary
% image and label them:
%
%     % binary (black-n-white) image
%     src = cv.imread('bw.png', 'Flags',0);
%     src = logical(src > 0);
%
%     [contours,hierarchy] = cv.findContours(src, 'Mode','CComp', ...
%         'Method','Simple');
%
%     % iterate through all the top-level contours,
%     % draw each connected component with its own random color
%     dst = zeros([size(src),3], 'uint8');
%     idx = 0;
%     while idx >= 0
%         color = randi([0 255], [1 3], 'uint8');
%         dst = cv.drawContours(dst, contours, 'ContourIdx',idx, ...
%             'Color',color, 'Thickness','Filled', 'LineType',8, ...
%             'Hierarchy',hierarchy);
%         idx = hierarchy{idx+1}(1);
%     end
%
%     subplot(121), imshow(src), title('Source')
%     subplot(122), imshow(dst), title('Components')
%
% ### Note
% When `Thickness='Filled'`, the function is designed to handle connected
% components with holes correctly even when no hierarchy date is provided.
% This is done by analyzing all the outlines together using even-odd rule.
% This may give incorrect results if you have a joint collection of separately
% retrieved contours. In order to solve this problem, you need to call
% cv.drawContours separately for each sub-group of contours, or iterate over
% the collection using `ContourIdx` parameter.
%
% See also: cv.findContours, cv.fillPoly, visboundaries, bwlabel
%

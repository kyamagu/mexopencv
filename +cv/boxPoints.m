%BOXPOINTS  Finds the four vertices of a rotated rectangle
%
%    points = cv.boxPoints(box)
%
% ## Input
% * __box__ The input rotated rectangle. A structure with the following
%       fields:
%       * __center__ The rectangle mass center `[x,y]`.
%       * __size__ Width and height of the rectangle `[w,h]`.
%       * __angle__ The rotation angle in a clockwise direction.
%             When the angle is 0, 90, 180, 270 etc., the
%             rectangle becomes an up-right rectangle.
%
% ## Output
% * __points__ The output array of four vertices of rectangles. A 4-by-2
%       numeric matrix, each row a point: `[x1 y1; x2 y2; x3 y3; x4 y4]`.
%
% The function finds the four vertices of a rotated rectangle. This function
% is useful to draw the rectangle. You can also use cv.RotatedRect.points
% method. Please visit the tutorial on bounding rectangle for more information.
%
% See also: cv.RotatedRect
%

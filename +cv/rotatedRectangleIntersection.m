%ROTATEDRECTANGLEINTERSECTION  Finds out if there is any intersection between two rotated rectangles.
%
%    [intersectingRegion,result] = cv.rotatedRectangleIntersection(rect1, rect2)
%
% ## Input
% * __rect1__ First rectangle. Structure with the following fields:
%       * __center__ The rectangle mass center `[x,y]`.
%       * __size__ Width and height of the rectangle `[w,h]`.
%       * __angle__ The rotation angle in a clockwise direction.
%             When the angle is 0, 90, 180, 270 etc., the
%             rectangle becomes an up-right rectangle.
% * __rect2__ Second rectangle. Similar struct to first.
%
% ## Output
% * __intersectingRegion__ The output array of the verticies of the
%       intersecting region. It returns at most 8 vertices. A cell array of
%       2D points `{[x,y], ...}`
% * __result__ types of intersection between rectangles. One of:
%       * __None__ No intersection.
%       * __Partial__ There is a partial intersection.
%       * __Full__ One of the rectangle is fully enclosed in the other.
%
% Finds out if there is any intersection between two rotated rectangles.
% If there is then the vertices of the interesecting region are returned as
% well.
%

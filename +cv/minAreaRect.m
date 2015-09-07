%MINAREARECT  Finds a rotated rectangle of the minimum area enclosing the input 2D point set
%
%    rct = cv.minAreaRect(points)
%
% ## Input
% * __points__ Input vector of 2D points, stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%
% ## Output
% * __rct__ Output rotated rectangle struct with the following fields:
%       * __center__ The rectangle mass center `[x,y]`.
%       * __size__ Width and height of the rectangle `[w,h]`.
%       * __angle__ The rotation angle in a clockwise direction.
%             When the angle is 0, 90, 180, 270 etc., the
%             rectangle becomes an up-right rectangle.
%
% The function calculates and returns the minimum-area bounding rectangle
% (possibly rotated) for a specified point set. Developer should keep in mind
% that the returned `rct` can contain negative indices when data is close to
% the containing Mat element boundary.
%
% See also: cv.fitEllipse, cv.convexHull
%

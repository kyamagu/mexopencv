%POINTPOLYGONTEST  Performs a point-in-contour test
%
%    d = cv.pointPolygonTest(contour, pt)
%    d = cv.pointPolygonTest(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __contour__ Input contour, stored in numeric array (Nx2/Nx1x2/1xNx2) or
%       cell array of 2-element vectors (`{[x,y], ...}`).
% * __pt__ Point tested against the contour `[x,y]`.
%
% ## Output
% * __d__ Output value (See below).
%
% ## Options
% * __MeasureDist__ If true, the function estimates the signed distance from
%          the point to the nearest contour edge. Otherwise, the function only
%          checks if the point is inside a contour or not. default false
%
% The function determines whether the point is inside a contour, outside, or
% lies on an edge (or coincides with a vertex). It returns positive (inside),
% negative (outside), or zero (on an edge) value, correspondingly. When
% `MeasureDist=false`, the return value is +1, -1, and 0, respectively.
% Otherwise, the return value is a signed distance between the point and the
% nearest contour edge.
%
% See also: cv.distanceTransform, inpolygon
%

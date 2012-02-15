%POINTPOLYGONTEST  Performs a point-in-contour test
%
%    d = cv.pointPolygonTest(contour, pt)
%
% ## Input
% * __contour__ Input 2D point set, stored in a cell array of 2-element vectors or
%         1-by-N-by-2 numeric array.
% * __pt__ Point tested against the contour.
%
% ## Output
% * __rct__ Output status value (See below).
%
% ## Options
% * __MeasureDist__ If true, the function estimates the signed distance from
%          the point to the nearest contour edge. Otherwise, the function only
%          checks if the point is inside a contour or not.
%
% The function determines whether the point is inside a contour, outside, or
% lies on an edge (or coincides with a vertex). It returns positive (inside),
% negative (outside), or zero (on an edge) value, correspondingly. When
% measureDist=false , the return value is +1, -1, and 0, respectively.
% Otherwise, the return value is a signed distance between the point and the
% nearest contour edge.
%

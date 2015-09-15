%CONVERTPOINTSTOHOMOGENEOUS  Converts points from Euclidean to homogeneous space
%
%    dst = cv.convertPointsToHomogeneous(src)
%
% ## Input
% * __src__ Input vector of N-dimensional points (2D/3D points).
%       Mx2/Mx1x2/1xMx2 or Mx3/Mx1x3/1xMx3 numeric array, or cell-array of
%       2/3-element vectors in the form: `{[x,y], [x,y], ...}` or
%       `{[x,y,z], [x,y,z], ...}`. Supports floating-point types.
%
% ## Output
% * __dst__ Output vector of (N+1)-dimensional points (3D/4D points).
%       Mx3/Mx1x3 or Mx4/Mx1x4 numeric array, or cell-array of 3/4-elements
%       vectors, respectively matching the input shape.
%
% The function converts points from Euclidean to homogeneous space by
% appending 1's to the tuple of point coordinates. That is, each point
% `(x1, x2, ..., xn)` is converted to `(x1, x2, ..., xn, 1)`.
%
% See also: cv.convertPointsFromHomogeneous
%

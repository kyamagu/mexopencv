%CONVERTPOINTSFROMHOMOGENEOUS  Converts points from homogeneous to Euclidean space
%
%    dst = cv.convertPointsFromHomogeneous(src)
%
% ## Input
% * __src__ Input vector of N-dimensional points (3D/4D points).
%       Mx3/Mx1x3/1xMx3 or Mx4/Mx1x4/1xMx4 numeric array, or cell-array of
%       3/4-element vectors in the form: `{[x,y,z], [x,y,z], ...}` or
%       `{[x,y,z,w], [x,y,z,w], ...}`. Supports floating-point types.
%
% ## Output
% * __dst__ Output vector of (N-1)-dimensional points (2D/3D points).
%       Mx2/Mx1x2 or Mx3/Mx1x3 numeric array, or cell-array of 2/3-elements
%       vectors, respectively matching the input shape.
%
% The function converts points homogeneous to Euclidean space using
% perspective projection. That is, each point `(x1, x2, ..., x(n-1), xn)` is
% converted to `(x1/xn, x2/xn, ..., x(n-1)/xn)`. When `xn=0`, the output point
% coordinates will be `(0,0,0,...)`.
%
% See also: cv.convertPointsToHomogeneous
%

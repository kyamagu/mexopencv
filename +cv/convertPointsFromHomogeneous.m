%CONVERTPOINTSFROMHOMOGENEOUS  Converts points from homogeneous to Euclidean space
%
%    dst = cv.convertPointsFromHomogeneous(src)
%
% ## Input
% * __src__ Input vector of N-dimensional points.
%
% ## Output
% * __dst__ Output vector of N-1-dimensional points.
%
% The function converts points homogeneous to Euclidean space using
% perspective projection. That is, each point (x1, x2, ... x(n-1), xn) is
% converted to (x1/xn, x2/xn, ..., x(n-1)/xn). When xn=0, the output point
% coordinates will be (0,0,0,...).
%
% See also cv.convertPointsToHomogeneous
%

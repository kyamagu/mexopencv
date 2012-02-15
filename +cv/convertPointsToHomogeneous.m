%CONVERTPOINTSTOHOMOGENEOUS  Converts points from Euclidean to homogeneous space
%
%    dst = cv.convertPointsToHomogeneous(src)
%
% ## Input
% * __src__ Input vector of N-dimensional points.
%
% ## Output
% * __dst__ Output vector of N+1-dimensional points.
%
% The function converts points from Euclidean to homogeneous space by
% appending 1?s to the tuple of point coordinates. That is, each point (x1,
% x2, ..., xn) is converted to (x1, x2, ..., xn, 1).
%
% See also cv.convertPointsFromHomogeneous
%

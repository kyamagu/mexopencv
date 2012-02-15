%CONVERTMAPS  Converts image transformation maps from one representation to another
%
%    [map1, map2] = cv.convertMaps(X, Y)
%    [map1, map2] = cv.convertMaps(XY)
%
% ## Input
% * __src__ Source image.
% * __X__ x values of the transformation, M-by-N-by-1 array
% * __Y__ y values of the transformation, M-by-N-by-1 array
% * __XY__ (x,y) values of the transformation, M-by-N-by-2 array
%
% ## Output
% * __map1__ The first map of the fixed-point representation, int16 type
% * __map2__ The second map of the fixed-point representation, uint16 type
%
% The function converts a pair of maps for cv.remap from one representation to
% another
%
% See also cv.remap
%

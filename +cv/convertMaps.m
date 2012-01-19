%CONVERTMAPS  Converts image transformation maps from one representation to another
%
%    [map1, map2] = cv.convertMaps(X, Y)
%    [map1, map2] = cv.convertMaps(XY)
%
%  Input:
%    src: Source image.
%      X: x values of the transformation, M-by-N-by-1 array
%      Y: y values of the transformation, M-by-N-by-1 array
%     XY: (x,y) values of the transformation, M-by-N-by-2 array
%  Output:
%   map1: The first map of the fixed-point representation, int16 type
%   map2: The second map of the fixed-point representation, uint16 type
%
% The function converts a pair of maps for cv.remap from one representation to
% another
%
% See also cv.remap
%
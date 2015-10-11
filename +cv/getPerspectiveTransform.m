%GETPERSPECTIVETRANSFORM  Calculates a perspective transform from four pairs of the corresponding points
%
%    T = cv.getPerspectiveTransform(src, dst)
%
% ## Input
% * __src__ Coordinates of quadrangle vertices in the source image. A numeric
%       4-by-2 row vectors or a cell-array of 2-element vectors of length 4
%       `{[x,y], [x,y], [x,y], [x,y]}`
% * __dst__ Coordinates of the corresponding quadrangle vertices in the
%       destination image. Same type and size as `src`.
%
% ## Output
% * __T__ 3-by-3 perspective transformation matrix
%
% The function calculates the 3x3 matrix of a perspective transform so that:
%
%     t_i * [X_i; Y_i; 1] = T * [x_i; y_i; 1]
%
% where
%
%     dst(i,:) = [X_i, Y_i], src(i,:) = [x_i, y_i]  for i=1,2,3
%
% See also: cv.findHomography, cv.warpPerspective, cv.perspectiveTransform,
%  cp2tform, fitgeotrans, estimateGeometricTransform
%

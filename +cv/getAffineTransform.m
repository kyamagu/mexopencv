%GETAFFINETRANSFORM  Calculates an affine transform from three pairs of the corresponding points
%
%    T = cv.getAffineTransform(src, dst)
%
% ## Input
% * __src__ Coordinates of triangle vertices in the source image. A numeric
%       3-by-2 row vectors or a cell-array of 2-element vectors of length 3
%       `{[x,y], [x,y], [x,y]}`
% * __dst__ Coordinates of the corresponding triangle vertices in the
%       destination image. Same type and size as `src`.
%
% ## Output
% * __T__ 2-by-3 affine transformation matrix
%
% The function calculates the 2x3 matrix of an affine transform so that:
%
%     [X_i; X_i] = T * [x_i; y_i; 1]
%
% where
%
%     dst(i,:) = [X_i, Y_i], src(i,:) = [x_i, y_i]  for i=1,2,3
%
% See also: cv.warpAffine, cv.transform, cp2tform, fitgeotrans,
%  estimateGeometricTransform
%

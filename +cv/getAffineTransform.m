%GETAFFINETRANSFORM  Calculates an affine transform from three pairs of the corresponding points
%
%    T = getAffineTransform(src, dst)
%
%  Input:
%    src: 3-by-2 row vectors of coordinates of triangle vertices in the source
%         image.
%	 dst: 3-by-2 row vectors of coordinates of the corresponding triangle
%         vertices in the destination image.
%  Output:
%    T:   2-by-3 transformation matrix
%
% The function calculates the 2 × 3 matrix of an affine transform so that
% 
%     [X_i; X_i] = T * [x_i; y_i; 1]
% 
% where
%
%     dst(i,:) = [X_i, Y_i], src(i,:) = [x_i, y_i]
%
% See also transform
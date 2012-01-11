%GETPERSPECTIVETRANSFORM  Calculates a perspective transform from four pairs of the corresponding points
%
%    T = getPerspectiveTransform(src, dst)
%
%  Input:
%    src: 4-by-2 row vectors of coordinates of quadrangle vertices in the source image
%         image.
%	 dst: 4-by-2 row vectors of the corresponding quadrangle vertices in the
%         destination image.
%  Output:
%    T:   3-by-3 transformation matrix
%
% The function calculates the 3 × 3 matrix of a perspective transform so that
% 
%     t_i * [X_i; X_i; 1] = T * [x_i; y_i; 1];
% 
% where
%
%     dst(i,:) = [X_i, Y_i], src(i,:) = [x_i, y_i]
%
% See also cv.perspectiveTransform
%
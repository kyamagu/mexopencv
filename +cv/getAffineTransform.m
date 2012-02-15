%GETAFFINETRANSFORM  Calculates an affine transform from three pairs of the corresponding points
%
%    T = cv.getAffineTransform(src, dst)
%
% ## Input
% * __src__ 3-by-2 row vectors of coordinates of triangle vertices in the source
%         image.
% * __dst__ 3-by-2 row vectors of coordinates of the corresponding triangle
%         vertices in the destination image.
%
% ## Output
% * __T__ 2-by-3 transformation matrix
%
% The function calculates the 2 x 3 matrix of an affine transform so that
% 
%     [X_i; X_i] = T * [x_i; y_i; 1]
% 
% where
%
%     dst(i,:) = [X_i, Y_i], src(i,:) = [x_i, y_i]
%
% See also cv.warpAffine
%

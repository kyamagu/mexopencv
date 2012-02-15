%GETROTATIONMATRIX2D  Calculates an affine matrix of 2D rotation
%
%    T = cv.getRotationMatrix2D(center, angle, scale)
%
% ## Input
% * __center__ Center of the rotation in the source image.
% * __angle__ Rotation angle in degrees. Positive values mean counter-clockwise
%           rotation (the coordinate origin is assumed to be the top-left
%           corner).
% * __scale__ Isotropic scale factor.
%
% ## Output
% * __T__ The output affine transformation, 2x3 floating-point matrix.
%
% The function calculates the following matrix:
% 
%     [ a, b, (1-a)*center.x-b*center.y ;
%      -b, a, b*center.x+(1-a)*center.y ]
% 
% where
%
%     a = scale * cos(angle)
%     b = scale * sin(angle)
%
% See also cv.getAffineTransform, cv.warpAffine
%

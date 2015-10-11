%GETROTATIONMATRIX2D  Calculates an affine matrix of 2D rotation
%
%    M = cv.getRotationMatrix2D(center, angle, scale)
%
% ## Input
% * __center__ Center of the rotation in the source image `[x,y]`.
% * __angle__ Rotation angle in degrees. Positive values mean counter-clockwise
%       rotation (the coordinate origin is assumed to be the top-left corner).
% * __scale__ Isotropic scale factor.
%
% ## Output
% * __M__ The output affine transformation, 2x3 double matrix.
%
% The function calculates the following matrix:
%
%     [ a, b, (1-a)*center(1) - b*center(2) ;
%      -b, a, b*center(1) + (1-a)*center(2) ]
%
% where
%
%     a = scale * cos(angle)
%     b = scale * sin(angle)
%
% The transformation maps the rotation center to itself. If this is not the
% target, adjust the shift.
%
% See also: cv.getAffineTransform, cv.warpAffine, cv.transform
%

%INVERTAFFINETRANSFORM  Inverts an affine transformation
%
%    iM = cv.invertAffineTransform(M)
%
% ## Input
% * __M__ Original affine transformation, a 2x3 floating-point matrix.
%
% ## Output
% * __iM__ Output reverse affine transformation, same size and type as `M`.
%
% The function computes an inverse affine transformation represented by 2x3
% matrix `M`:
%
%     [a_11, a_12, b_1; a_21, a_22, b_2]
%
% The result is also a 2x3 matrix of the same type as `M`.
%

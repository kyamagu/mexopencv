%INVERTAFFINETRANSFORM  Inverts an affine transformation
%
%    iM = invertAffineTransform(M)
%
%  Input:
%    M: Original affine transformation.
%  Output:
%    iM: Output reverse affine transformation.
%
% The function computes an inverse affine transformation represented by 2 x 3
% matrix M :
% 
%     [a_11, a_12, b_1; a_21, a_22, b_2]
% 
% The result is also a 2 x 3 matrix of the same type as M.
%
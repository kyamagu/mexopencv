%PEILINNORMALIZATION  Calculates an affine transformation that normalize given image using Pei/Lin Normalization
%
%     T = cv.PeiLinNormalization(I)
%
% ## Input
% * __I__ Given transformed image.
%
% ## Output
% * __T__ 2x3 transformation matrix corresponding to inversed image
%   transformation.
%
% Assume given image `I = T(Ibar)` where `Ibar` is a normalized image and `T`
% is an affine transformation distorting this image by translation, rotation,
% scaling and skew. The function returns an affine transformation matrix
% corresponding to the transformation `T_inv` described in [PeiLin95]. For
% more details about this implementation, please see [PeiLin95].
%
% ## References
% [PeiLin95]:
% > Soo-Chang Pei and Chao-Nan Lin. "Image normalization for pattern
% > recognition". Image and Vision Computing, Vol. 13, N.10, pp. 711-723, 1995.
%
% See also:
%

%BLENDLINEAR  Performs linear blending of two images
%
%     dst = cv.blendLinear(src1, src2, weights1, weights2)
%
% ## Input
% * __src1__ First image, it has a depth of `uint8` or `single`, and any
%   number of channels.
% * __src2__ second image of same size and type as `src1`.
% * __weights1__ floating-point matrix of size same as input images.
% * __weights2__ floating-point matrix of size same as input images.
%
% ## Output
% * __dst__ blended image, of same size and type as input images.
%
% Performs linear blending of two images:
%
%     dst(i,j) = weights1(i,j) * src1(i,j) + weights2(i,j) * src2(i,j)
%
% See also: cv.addWeighted, cv.add, imlincomb
%

%MATMULDERIV  Computes partial derivatives of the matrix product for each multiplied matrix
%
%    [dABdA, dABdB] = cv.matMulDeriv(A, B)
%
% ## Input
% * __A__ First multiplied matrix.
% * __B__ Second multiplied matrix.
%
% ## Output
% * __dABdA__ First output derivative matrix d(A*B)/dA of size A.rows *
%        B.cols x A.rows * A.cols.
% * __dABdB__ Second output derivative matrix d(A*B)/dB of size A.rows * 
%        B.cols x B.rows * B.cols.
%
% The function computes partial derivatives of the elements of the matrix
% product A*B with regard to the elements of each of the two input
% matrices. The function is used to compute the Jacobian matrices in
% cv.stereoCalibrate but can also be used in any other similar optimization
% function.
%
% See also cv.stereoCalibrate
%

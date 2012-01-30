%MATMULDERIV  Computes partial derivatives of the matrix product for each multiplied matrix
%
%   [dABdA, dABdB] = cv.matMulDeriv(A, B)
%
% Input:
%    A: First multiplied matrix.
%    B: Second multiplied matrix.
% Output:
%    dABdA: First output derivative matrix d(A*B)/dA of size A.rows *
%        B.cols x A.rows * A.cols.
%    dABdB: Second output derivative matrix d(A*B)/dB of size A.rows * 
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
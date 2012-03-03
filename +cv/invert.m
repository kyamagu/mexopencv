%INVERT Finds the inverse or pseudo-inverse of a matrix
%
%    dst = cv.invert(src)
%    [dst,d] = cv.invert(...)
%    [...] = cv.invert(...,'OptionName',optionValue,...)
%
% ## Input
% * __src__ Source floating-point M x N matrix.
%
% ## Output
% * __dst__ Destination matrix of N x M size and the same type as src.
% * __d__ Output value depending on the method. See below.
%
% ## Options
% * __Method__ Inversion method. One of the following:
%     * __LU__ Gaussian elimination with the optimal pivot element chosen.
%     * __SVD__ Singular value decomposition (SVD) method.
%     * __Cholesky__ Cholesky decomposion. The matrix must be symmetrical
%         and positively defined.
%
% The function invert inverts the matrix src and stores the result in dst.
% When the matrix src is singular or non-square, the function computes the
% pseudo-inverse matrix (the dst matrix) so that `norm(src*dst - I)` is
% minimal, where I is an identity matrix.
%
% In case of the `'LU'` method, the function returns the src determinant (
% src must be square). If it is 0, the matrix is not inverted and dst is
% filled with zeros.
%
% In case of the `'SVD'` method, the function returns the inverse condition
% number of src (the ratio of the smallest singular value to the largest
% singular value) and 0 if src is singular. The SVD method calculates a
% pseudo-inverse matrix if src is singular.
%
% Similarly to `'LU'`, the method `'Cholesky'` works only with
% non-singular square matrices that should also be symmetrical and
% positively defined. In this case, the function stores the inverted matrix
% in dst and returns non-zero. Otherwise, it returns 0.
%

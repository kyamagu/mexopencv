%EIGEN  Calculates eigenvalues and eigenvectors of a symmetric matrix
%
%     evals = cv.eigen(src)
%     [evals, evects, b] = cv.eigen(src)
%
% ## Input
% * __src__ input matrix that must have single or double type, square size and
%   be symmetrical (`src' == src`).
%
% ## Output
% * __evals__ output vector of eigenvalues of the same type as `src`;
%   the eigenvalues are stored in the descending order.
% * __evects__ output matrix of eigenvectors; it has the same size and
%   type as `src`; the eigenvectors are stored as subsequent matrix rows, in
%   the same order as the corresponding `evals`.
% * __b__ bool return value
%
% The function cv.eigen calculates just eigenvalues, or eigenvalues and
% eigenvectors of the symmetric matrix `src`:
%
%     src * evects(i,:)' = evals(i) * evects(i,:)'
%
% Note: Use cv.eigenNonSymmetric for calculation of real eigenvalues and
% eigenvectors of non-symmetric matrix.
%
% See also: cv.eigenNonSymmetric, cv.PCA, eig
%

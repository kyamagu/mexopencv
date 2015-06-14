%EIGEN  Calculates eigenvalues and eigenvectors of a symmetric matrix
%
%    eigenvalues = cv.eigen(src)
%    [eigenvalues,eigenvectors,b] = cv.eigen(src)
%
% ## Input
% * __src__ input matrix that must have single or double type, square size
%       and be symmetrical (`src' == src`).
%
% ## Output
% * __eigenvalues__ output vector of eigenvalues of the same type as `src`;
%       the eigenvalues are stored in the descending order.
% * __eigenvectors__ output matrix of eigenvectors; it has the same size and
%       type as `src`; the eigenvectors are stored as subsequent matrix rows,
%       in the same order as the corresponding `eigenvalues`.
% * __b__ bool return value
%
% The functions cv.eigen calculate just eigenvalues, or eigenvalues and
% eigenvectors of the symmetric matrix `src`:
%
%    src*eigenvectors(i,:)' = eigenvalues(i)*eigenvectors(i,:)'
%
% See also: cv.PCA, eig
%

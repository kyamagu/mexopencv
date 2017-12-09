%EIGENNONSYMMETRIC  Calculates eigenvalues and eigenvectors of a non-symmetric matrix (real eigenvalues only)
%
%     evals = cv.eigenNonSymmetric(src)
%     [evals, evects] = cv.eigenNonSymmetric(src)
%
% ## Input
% * __src__ input square matrix (`single` or `double` type, single-channel).
%
% ## Output
% * __evals__ output vector of eigenvalues of the same type as `src`
% * __evects__ output matrix of eigenvectors of the same type as `src`.
%   The eigenvectors are stored as subsequent matrix rows, in the same order
%   as the corresponding `evals`.
%
% The function calculates eigenvalues and eigenvectors (optional) of the
% square matrix `src`:
%
%     src * evects(i,:)' = evals(i) * evects(i,:)'
%
% Note: Assumes real eigenvalues.
%
% See also: cv.eigen, eig
%

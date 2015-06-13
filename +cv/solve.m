%SOLVE  Solves one or more linear systems or least-squares problems.
%
%    [dst,ret] = cv.solve(src1, src2)
%    [...] = cv.solve(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src1__ input matrix on the left-hand side of the system.
% * __src2__ input matrix on the right-hand side of the system.
%
% ## Output
% * __dst__ output solution.
% * __ret__ Logical return value, see below.
%
% ## Options
% * __Method__ solution (matrix inversion) method, default 'LU'. One of the
%     following matrix decomposition types:
%     * __LU__ Gaussian elimination with the optimal pivot element chosen.
%     * __SVD__ singular value decomposition (SVD) method; the system can be
%           over-defined and/or the matrix `src1` can be singular
%     * __EIG__ eigenvalue decomposition; the matrix `src1` must be symmetrical
%     * __Cholesky__ Cholesky LLT factorization; the matrix `src1` must be
%           symmetrical and positively defined
%     * __QR__ QR factorization; the system can be over-defined and/or the
%           matrix `src1` can be singular
% * __IsNormal__ this flag can be used together with any of the previous methods;
%       it means that the normal equations `src1' * src1 * dst = src1' * src2`
%       are solved instead of the original system `src1 * dst = src2`.
%       defaul false
%
% The function cv.solve solves a linear system or least-squares problem (the
% latter is possible with 'SVD' or 'QR' methods, or by specifying the flag
% 'IsNormal'):
%
%    dst = argmin_{X} ||src1*X - src2||
%
% If 'LU' or 'Cholesky' method is used, the function returns 1 if `src1`
% (or `src1'*src1`) is non-singular. Otherwise, it returns 0. In the latter
% case, `dst` is not valid. Other methods find a pseudo-solution in case of a
% singular left-hand side part.
%
% ## Note
% If you want to find a unity-norm solution of an under-defined singular
% system `src1 * dst = 0`, the function cv.solve will not do the work.
% Use cv.SVD.SolveZ instead.
%
% See also: cv.invert, cv.SVD, cv.eigen, mldivide, inv, svd, eig
%

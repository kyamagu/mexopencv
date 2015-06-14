%SOLVELP  Solve given (non-integer) linear programming problem using the Simplex Algorithm.
%
%    [z, res] = cv.solveLP(Func, Constr)
%    [...] = cv.solveLP(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __Func__ This row-vector corresponds to `c` in the LP problem formulation
%       (see below). It should contain 32- or 64-bit floating point numbers.
%       As a convenience, column-vector may be also submitted, in the latter
%       case it is understood to correspond to `c'`.
% * __Constr__ m-by-n+1 matrix, whose rightmost column corresponds to `b` in
%       formulation above and the remaining to `A`. It should containt 32- or
%       64-bit floating point numbers.
%
% ## Output
% * __z__ The solution will be returned here as a column-vector - it
%       corresponds to `x` in the formulation above. It will contain 64-bit
%       floating point numbers.
% * __res__ Return code. One of:
%       * __Unbounded__ problem is unbounded (target function can achieve
%             arbitrary high values)
%       * __Unfeasible__ problem is unfeasible (there are no points that
%             satisfy all the constraints imposed)
%       * __Single__ there is only one maximum for target function
%       * __Multi__ there are multiple maxima for target function - the
%             arbitrary one is returned
%
% What we mean here by "linear programming problem" (or LP problem, for short)
% can be formulated as:
%
%     Maximize c*x
%      subject to  A*x <= b
%                  x >= 0
%
% Where `c` is fixed 1-by-n row-vector, `A` is fixed m-by-n matrix, `b` is
% fixed m-by-1 column vector and `x` is an arbitrary n-by-1 column vector,
% which satisfies the constraints.
%
% Simplex algorithm is one of many algorithms that are designed to handle this
% sort of problems efficiently. Although it is not optimal in theoretical
% sense (there exist algorithms that can solve any problem written as above in
% polynomial type, while simplex method degenerates to exponential time for
% some special cases), it is well-studied, easy to implement and is shown to
% work well for real-life purposes.
%
% The particular implementation is taken almost verbatim from:
%
% > Introduction to Algorithms, 3rd edition
% > by T. H. Cormen, C. E. Leiserson, R. L. Rivest and Clifford Stein.
%
% In particular, the Bland's rule http://en.wikipedia.org/wiki/Bland%27s_rule
% is used to prevent cycling.
%
% See also: linprog
%

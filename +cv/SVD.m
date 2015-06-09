classdef SVD < handle
    %SVD  Singular Value Decomposition
    %
    % Class for computing Singular Value Decomposition of a floating-point
    % matrix. The Singular Value Decomposition is used to solve
    % least-square problems, under-determined linear systems, invert
    % matrices, compute condition numbers, and so on.
    %
    % If you want to compute a condition number of a matrix or an absolute
    % value of its determinant, you do not need `u` and `vt`. You can pass
    % 'NoUV' flag. Another flag 'FullUV' indicates that full-size
    % `u` and `vt` must be computed, which is not necessary most of the time.
    %
    % See also: cv.SVD.compute
    %

    properties (SetAccess = protected)
        id    % Object ID
    end

    properties (Dependent)
        % left singular vectors
        u
        % singular values
        w
        % transposed matrix of right singular vectors
        vt
    end

    methods
        function this = SVD(varargin)
            %SVD  Default constructor
            %
            %    svd = cv.SVD()
            %    svd = cv.SVD(src, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __src__ decomposed matrix.
            %
            % ## Options
            % Same option as cv.SVD.compute() method.
            %
            % In the first form, it initializes an empty SVD structure.
            % In the second form, it initializes an empty SVD structure and
            % then calls cv.SVD.compute().
            %
            % See also: cv.SVD.compute
            %
            this.id = SVD_(0, 'new');
            if nargin > 0
                this.compute(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            SVD_(this.id, 'delete');
        end

        function compute(this, A, varargin)
            %COMPUTE  the operator that performs SVD
            %
            %    svd.compute(A)
            %    svd.compute(A, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __A__ decomposed matrix, `A = u*diag(w)*vt`
            %
            % ## Options
            % * __Flags__ operation flags. default 0
            % * __ModifyA__ allow the algorithm to modify the decomposed
            %       matrix; it can save space and speed up processing.
            %       currently ignored. default false
            % * __NoUV__ indicates that only a vector of singular values `w`
            %       is to be processed, while `u` and `vt` will be set to
            %       empty matrices. default false
            % * __FullUV__ when the matrix is not square, by default the
            %       algorithm produces `u` and `vt` matrices of sufficiently
            %       large size for the further `A` reconstruction; if,
            %       however, `FullUV` flag is specified, `u` and `vt` will be
            %       full-size square orthogonal matrices. default false
            %
            % The previously allocated `u`, `w` and `vt` are released.
            %
            % The operator performs the singular value decomposition of the
            % supplied matrix. The `u`, `vt`, and the vector of singular
            % values `w` are stored in the structure. The same SVD structure
            % can be reused many times with different matrices. Each time, if
            % needed, the previous `u`, `vt`, and `w` are reclaimed and the
            % new matrices are created.
            %
            SVD_(this.id, 'compute', A, varargin{:});
        end

        function dst = backSubst(this, src)
            %BACKSUBST  performs a singular value back substitution
            %
            %    dst = svd.backSubst(src)
            %
            % ## Input
            % * __src__ right-hand side of a linear system `(u*w*v')*dst = src`
            %       to be solved, where `A` has been previously decomposed
            %       into `u`, `w`, and `vt` (stored in class).
            %
            % ## Output
            % * __dst__ found solution of the system.
            %
            % The method calculates a back substitution for the specified
            % right-hand side.
            %
            %    x = vt^T * diag(w)^-1 * u^T * src
            %      ~ A^-1* src
            %
            % Using this technique you can either get a very accurate
            % solution of the convenient linear system, or the best (in the
            % least-squares terms) pseudo-solution of an overdetermined
            % linear system.
            %
            % ## Note
            % Explicit SVD with the further back substitution only
            % makes sense if you need to solve many linear systems with the
            % same left-hand side (for example, `src`). If all you need is to
            % solve a single system (possibly with multiple `rhs` immediately
            % available), simply call `solve` add pass 'SVD' there. It does
            % absolutely the same thing.
            %
            % See also: cv.SVD.compute
            %
            dst = SVD_(this.id, 'backSubst', src);
        end
    end

    methods
        function value = get.u(this)
            value = SVD_(this.id, 'get', 'u');
        end
        function set.u(this, value)
            SVD_(this.id, 'set', 'u', value);
        end

        function value = get.vt(this)
            value = SVD_(this.id, 'get', 'vt');
        end
        function set.vt(this, value)
            SVD_(this.id, 'set', 'vt', value);
        end

        function value = get.w(this)
            value = SVD_(this.id, 'get', 'w');
        end
        function set.w(this, value)
            SVD_(this.id, 'set', 'w', value);
        end
    end

    methods (Static)
        function [w, u, vt] = Compute(A, varargin)
            %COMPUTE  Performs SVD of a matrix
            %
            %    [w, u, vt] = cv.SVD.Compute(A)
            %    [...] = cv.SVD.Compute(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __A__ Decomposed matrix, A = u*diag(w)*vt
            %
            % ## Output
            % * __w__ Computed singular values
            % * __u__ Computed left singular vectors
            % * __vt__ Transposed matrix of right singular vectors
            %
            % ## Options
            % * __NoUV__ Use only singular values `w`. The algorithm does not
            %        compute `u` and `vt` matrices. default false
            % * __FullUV__ When the matrix is not square, by default the
            %        algorithm produces `u` and `vt` matrices of sufficiently
            %        large size for the further `A` reconstruction. If,
            %        however, the 'FullUV' flag is specified, `u` and `vt` are
            %        full-size square orthogonal matrices. default false
            %
            % The function perform SVD of matrix. Unlike the cv.SVD.compute()
            % method, it returns the results in the output matrices.
            %
            % See also: cv.SVD.solveZ, cv.SVD.backSubst
            %
            [w, u, vt] = SVD_(0, 'compute_static', A, varargin{:});
        end

        function dst = BackSubst(w, u, vt, src)
            %BACKSUBST  Performs back substitution
            %
            %    dst = cv.SVD.BackSubst(w, u, vt, src)
            %
            % ## Input
            % * __w__ Singular values
            % * __u__ Left singular vectors
            % * __vt__ Transposed matrix of right singular vectors
            % * __src__ Right-hand side of a linear system `(u*w*v')*dst = src`
            %        to be solved, where `A` has been previously decomposed
            %        into `u`, `w`, and `vt` (passed arguments).
            %
            % ## Output
            % * __dst__ Found solution of the system.
            %
            % The method computes a back substitution for the specified
            % right-hand side:
            %
            %    x = vt^T * diag(w)^-1 * u^T * src
            %      ~ A^-1* src
            %
            % Using this technique you can either get a very accurate
            % solution of the convenient linear system, or the best (in the
            % least-squares terms) pseudo-solution of an overdetermined
            % linear system.
            %
            % ## Note
            % Explicit SVD with the further back substitution only
            % makes sense if you need to solve many linear systems with the
            % same left-hand side (for example, `src`). If all you need is to
            % solve a single system (possibly with multiple `rhs` immediately
            % available), simply call `solve` and pass 'SVD' there. It does
            % absolutely the same thing.
            %
            % See also: cv.SVD.Compute, cv.SVD.SolveZ
            %
            dst = SVD_(0, 'backSubst_static', w, u, vt, src);
        end

        function dst = SolveZ(A)
            %SOLVEZ  Solves an under-determined singular linear system
            %
            %    dst = cv.SVD.SolveZ(A)
            %
            % ## Input
            % * __A__ Left-hand-side matrix.
            %
            % ## Output
            % * __dst__ Found solution `x`.
            %
            % The method finds a unit-length solution `x` of a singular
            % linear system `A*x = 0`. Depending on the rank of `A`, there can
            % be no solutions, a single solution or an infinite number of
            % solutions. In general, the algorithm solves the following
            % problem:
            %
            %    dst = argmin_{x: ||x||=1} || A * x ||
            %
            % See also: cv.SVD.Compute, cv.SVD.BackSubst
            %
            dst = SVD_(0, 'solveZ_static', A);
        end
    end

end

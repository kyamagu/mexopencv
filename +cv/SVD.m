classdef SVD
    %SVD  Class for computing Singular Value Decomposition of a floating-point matrix
    %
    % Class for computing Singular Value Decomposition of a floating-point
    % matrix. The Singular Value Decomposition is used to solve
    % least-square problems, under-determined linear systems, invert
    % matrices, compute condition numbers, and so on.
    %
    % If you want to compute a condition number of a matrix or an absolute
    % value of its determinant, you do not need u and vt. You can pass
    % 'NoUV' flag. Another flag 'FullUV' indicates that full-size
    % u and vt must be computed, which is not necessary most of the time.
    %
    % See also cv.SVD.compute
    %
    
    methods (Static)
        function [w, u, vt] = compute(A)
            %COMPUTE  Performs SVD of a matrix
            %
            %    [w, u, vt] = cv.SVD.compute(A)
            %    [...] = cv.SVD.compute(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __A__ Decomposed matrix
            %
            % ## Output
            % * __w__ Computed singular values
            % * __u__ Computed left singular vectors
            % * __vt__ Transposed matrix of right singular vectors
            %
            % ## Options
            % * __NoUV__ Use only singular values. The algorithm does not
            %        compute u and vt matrices. default false
            % * __FullUV__ When the matrix is not square, by default the
            %        algorithm produces u and vt matrices of sufficiently
            %        large size for the further A reconstruction. If,
            %        however, the 'FullUV' flag is specified, u and vt are
            %        full-size square orthogonal matrices. default false
            %
            % The methods/functions perform SVD of matrix.
            %
            % See also cv.SVD.solveZ cv.SVD.backSubst
            %
            [w, u, vt] = SVD_compute_(A);
        end
        
        function dst = solveZ(src)
            %SOLVEZ  Solves an under-determined singular linear system
            %
            %    dst = cv.SVD.solveZ(src)
            %
            % ## Input
            % * __src__ Left-hand-side matrix.
            %
            % ## Output
            % * __dst__ Found solution.
            %
            % The method finds a unit-length solution x of a singular
            % linear system A*x = 0. Depending on the rank of A, there can
            % be no solutions, a single solution or an infinite number of
            % solutions. In general, the algorithm solves the following
            % problem
            %
            %    dst = argmin_{x:||x||=1} || src * x ||
            %
            % See also cv.SVD.compute cv.SVD.backSubst
            %
            dst = SVD_solveZ_(src);
        end
        
        function dst = backSubst(w, u, vt, src)
            %BACKSUBST  Performs a singular value back substitution
            %
            %    dst = cv.SVD.backSubst(w, u, vt, src)
            %
            % ## Input
            % * __w__ Singular values
            % * __u__ Left singular vectors
            % * __vt__ Transposed matrix of right singular vectors
            % * __src__ Right-hand side of a linear system `(u*w*v')*dst = src`
            %        to be solved, where A has been previously decomposed.
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
            % same left-hand side (for example, src ). If all you need is
            % to solve a single system (possibly with multiple rhs
            % immediately available), simply call solve() add pass
            % DECOMP_SVD there. It does absolutely the same thing.
            %
            % See also cv.SVD.compute cv.SVD.solveZ
            %
            dst = SVD_backSubst_(w, u, vt, src);
        end
    end
    
end

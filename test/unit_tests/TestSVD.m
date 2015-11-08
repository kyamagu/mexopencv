classdef TestSVD
    %TestSVD

    methods (Static)
        function test_1
            A = magic(4);
            b = ones(4,1);
            [w,u,vt] = cv.SVD.Compute(A);
            x = cv.SVD.BackSubst(w, u, vt, b);
            assert(isvector(w));
            assert(ismatrix(u));
            assert(ismatrix(vt));
            assert(isvector(x));
            norm((u*diag(w)*vt) - A);
            norm(A*x - b);
        end

        function test_2
            A = randn(10);
            b = ones(10,1);
            [u,s,v] = svd(A);
            x = cv.SVD.BackSubst(diag(s), u, v', b);
            norm(A*x - b);
        end

        function test_3
            A = randn(10,10);
            b = ones(10,1);

            % [U,S,V] = svd(A);
            svd = cv.SVD();
            svd.compute(A);
            AA = svd.u * diag(svd.w) * svd.vt;
            norm(A - AA);

            % x = A\b;
            x = svd.backSubst(b);
            norm(AA*x - b);
        end

        function test_4
            A = magic(4);
            x = cv.SVD.SolveZ(A);
            abs(norm(A*x));                     % minimize ||A*x||
            assert(abs(norm(x) - 1.0) < 1e-6);  % such that ||x|| == 1
        end
    end

end

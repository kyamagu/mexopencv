classdef TestSVD
    %TestSVD
    properties (Constant)
    end

    methods (Static)
        function test_1
            A = magic(4);
            [w,u,vt] = cv.SVD.Compute(A);
            dst = cv.SVD.BackSubst(w,u,vt,ones(4,1));
        end

        function test_2
            A = magic(4);
            dst = cv.SVD.SolveZ(A);
        end

        function test_3
            A = magic(4);
            svd = cv.SVD();
            svd.compute(A);
            svd.w;
            svd.u;
            svd.vt;
            dst = svd.backSubst(ones(4,1));
        end
    end

end

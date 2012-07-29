classdef TestSVD
    %TestSVD
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            A = magic(4);
            [w,u,vt] = cv.SVD.compute(A);
            dst = cv.SVD.backSubst(w,u,vt,ones(4,1));
        end
        
        function test_2
            src = magic(4);
            dst = cv.SVD.solveZ(src);
        end
    end
    
end

classdef TestSolveLP
    %TestSolveLP

    methods (Static)
        function test_basic_1
            A = [3; 1; 2];
            B = [1,1,3,30; 2,2,5,24; 4,1,2,36];
            z = cv.solveLP(A,B);
            etalon_z = [8; 4; 0];
            assert(norm(z-etalon_z) < 1e-9);
        end

        function test_basic_2
            A = [18, 12.5];
            B = [1,1,20; 1,0,20; 0,1,16];
            z = cv.solveLP(A,B);
            etalon_z = [20; 0];
            assert(norm(z-etalon_z) < 1e-9);
        end

        function test_basic_3
            A = [5, -3];
            B = [1,-1,1; 2,1,2];
            z = cv.solveLP(A,B);
            etalon_z = [1; 0];
            assert(norm(z-etalon_z) < 1e-9);
        end

        function test_unfeasible_1
            A = [-1, -1, -1];
            B = [-2,-7.5,-3,-10000; -20,-5,-10,-30000];
            z = cv.solveLP(A,B);
            etalon_z = [1250; 1000; 0];
            assert(norm(z-etalon_z) < 1e-9);
        end

        function test_absolutely_unfeasible_1
            A = [1];
            B = [1,-1];
            [z,res] = cv.solveLP(A,B);
            assert(strcmp(res,'Unfeasible'));
        end

        function test_multiple_solutions_1
            A = [1; 1];
            B = [1, 1, 1];
            [z,res] = cv.solveLP(A,B);
            assert(strcmp(res,'Multi'));
            assert(abs(dot(A,z)-1) < 1e-12);
        end

        function test_cycling_1
            A = [10; -57; -9; -24];
            B = [0.5,-5.5,-2.5,9,0; 0.5,-1.5,-0.5,1,0; 1,0,0,0,1];
            [z,res] = cv.solveLP(A,B);
            assert(abs(dot(A,z)-1) < 1e-12);
        end

        function test_error_1
            try
                cv.solveLP();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

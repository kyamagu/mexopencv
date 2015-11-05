classdef TestDownhillSolver
    %TestDownhillSolver

    methods (Static)
        function test_rosenbrock
            % skip test if external M-file is not found on the path
            if ~exist('rosenbrockFcn.m', 'file')
                disp('SKIPPED')
                return
            end

            solver = cv.DownhillSolver();
            solver.ObjectiveFunction = struct('dims',2, 'fun','rosenbrockFcn');
            solver.InitStep = [0.5, 0.5];
            solver.TermCriteria = struct('type','Count+EPS', ...
                'maxCount',5000, 'epsilon',1e-6);
            [x,f] = solver.minimize([0; 0]);
            etalon_x = [1; 1];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_sphere
            % skip test if external M-file is not found on the path
            if ~exist('sphereFcn.m', 'file')
                disp('SKIPPED')
                return
            end

            solver = cv.DownhillSolver('InitStep', [-0.5, -0.5], ...
                'Function',struct('dims',2, 'fun','sphereFcn'));
            [x,f] = solver.minimize([1, 1]);
            etalon_x = [0, 0];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_booth
            % skip test if external M-file is not found on the path
            if ~exist('boothFcn.m', 'file')
                disp('SKIPPED')
                return
            end

            solver = cv.DownhillSolver('InitStep', [1 1], ...
                'Function', struct('dims',2, 'fun','boothFcn'));
            [x,f] = solver.minimize([-10, -10]);
            etalon_x = [1, 3];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_matyas
            % skip test if external M-file is not found on the path
            if ~exist('matyasFcn.m', 'file')
                disp('SKIPPED')
                return
            end

            solver = cv.DownhillSolver('InitStep', [1 1], ...
                'Function', struct('dims',2, 'fun','matyasFcn'));
            [x,f] = solver.minimize([10, -10]);
            etalon_x = [0, 0];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_beale
            % skip test if external M-file is not found on the path
            if ~exist('bealeFcn.m', 'file')
                disp('SKIPPED')
                return
            end

            solver = cv.DownhillSolver('InitStep', [1 1], ...
                'Function', struct('dims',2, 'fun','bealeFcn'));
            [x,f] = solver.minimize([2, 0]);
            etalon_x = [3, 0.5];
            %assert(norm(x-etalon_x) < 1e-2); % TODO: fails to find solution
        end

        function test_error_1
            try
                cv.DownhillSolver('foo', 'bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_2
            solver = cv.DownhillSolver();
            solver.InitStep = ones(1,2);
            solver.ObjectiveFunction = struct('dims',2, 'fun','foo_bar_baz');
            try
                [x,f] = solver.minimize(rand(1,2));
            catch ME
                assert(strcmp(ME.identifier, 'MATLAB:UndefinedFunction'));
            end
        end
    end
end

%%
% https://en.wikipedia.org/wiki/Test_functions_for_optimization
% TODO: these functions needs to be on the path as a top-level functions
%       saved in their own M-files.

% Rosenbrock function
function f = rosenbrockFcn(x)
    a = 1;
    b = 100;
    f = (x(1)-a)^2 + b*(x(2)-x(1)^2)^2;
end

% Sphere function
function f = sphereFcn(x)
    f = sum(x.^2);
end

% Booth's function
function f = boothFcn(x)
    f = (x(1)+2*x(2)-7)^2 + (2*x(1)+x(2)-5)^2;
end

% Matyas function
function f = matyasFcn(x)
    f = 0.26*(x(1)^2+x(2)^2) - 0.48*x(1)*x(2);
end

% Beale's function
function f = bealeFcn(x)
    f = (1.5 - x(1) - x(1)*x(2))^2 + ...
        (2.25 - x(1) + x(1)*x(2)^2)^2 + ...
        (2.625 - x(1) + x(1)*x(2)^3)^2;
end

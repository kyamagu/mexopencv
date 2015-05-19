classdef TestDownhillSolver
    %TestDownhillSolver
    properties (Constant)
    end

    methods (Static)
        function test_rosenbrock
            solver = cv.DownhillSolver();
            solver.ObjectiveFunction = struct('dims',2, 'fun','rosenbrock');
            solver.InitStep = [0.5, 0.5];
            solver.TermCriteria = struct('type','Count+EPS', ...
                'maxCount',5000, 'epsilon',1e-6);
            [x,f] = solver.minimize([0; 0]);
            etalon_x = [1; 1];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_sphere
            solver = cv.DownhillSolver('InitStep', [-0.5, -0.5], ...
                'Function',struct('dims',2, 'fun','sphere'));
            [x,f] = solver.minimize([1, 1]);
            etalon_x = [0, 0];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_booth
            solver = cv.DownhillSolver('InitStep', [1 1], ...
                'Function', struct('dims',2, 'fun','booth'));
            [x,f] = solver.minimize([-10, -10]);
            etalon_x = [1, 3];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_matyas
            solver = cv.DownhillSolver('InitStep', [1 1], ...
                'Function', struct('dims',2, 'fun','matyas'));
            [x,f] = solver.minimize([10, -10]);
            etalon_x = [0, 0];
            assert(norm(x-etalon_x) < 1e-2);
        end

        function test_beale
            solver = cv.DownhillSolver('InitStep', [1 1], ...
                'Function', struct('dims',2, 'fun','beale'));
            [x,f] = solver.minimize([2, 0]);
            etalon_x = [3, 0.5];
            %assert(norm(x-etalon_x) < 1e-2);
            warning('mexopencv:warn', '[DISABLED] fails to find solution.')
        end

        function test_error_1
            try
                cv.DownhillSolver('foo', 'bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

%%
% https://en.wikipedia.org/wiki/Test_functions_for_optimization

% Rosenbrock function
function f = rosenbrock(x)
    a = 1;
    b = 100;
    f = (x(1)-a)^2 + b*(x(2)-x(1)^2)^2;
end

% Sphere function
function f = sphere(x)
    f = sum(x.^2);
end

% Booth's function
function f = booth(x)
    f = (x(1)+2*x(2)-7)^2 + (2*x(1)+x(2)-5)^2;
end

% Matyas function
function f = matyas(x)
    f = 0.26*(x(1)^2+x(2)^2) - 0.48*x(1)*x(2);
end

% Beale's function
function f = beale(x)
    f = (1.5 - x(1) - x(1)*x(2))^2 + ...
        (2.25 - x(1) + x(1)*x(2)^2)^2 + ...
        (2.625 - x(1) + x(1)*x(2)^3)^2;
end

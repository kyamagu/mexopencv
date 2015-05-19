classdef TestConjGradSolver
    %TestConjGradSolver
    properties (Constant)
    end

    methods (Static)
        function test_rosenbrock
            solver = cv.ConjGradSolver();
            solver.ObjectiveFunction = struct('dims',2, ...
                'fun','rosenbrock', 'gradfun','rosenbrockGrad');
            solver.TermCriteria = struct('type','Count+EPS', ...
                'maxCount',5000, 'epsilon',1e-6);
            [x,f] = solver.minimize([0; 0]);
            etalon_x = [1; 1];
            assert(norm(x-etalon_x) < 1e-6);
        end

        function test_sphere
            solver = cv.ConjGradSolver('Function', ...
                struct('dims',4, 'fun','sphere', 'gradfun','sphereGrad'));
            [x,f] = solver.minimize([50, 10, 1, -10]);
            etalon_x = [0, 0, 0, 0];
            assert(norm(x-etalon_x) < 1e-6);
        end

        function test_booth
            solver = cv.ConjGradSolver('Function', ...
                struct('dims',2, 'fun','booth', 'gradfun','boothGrad'));
            [x,f] = solver.minimize([-10, -10]);
            etalon_x = [1, 3];
            assert(norm(x-etalon_x) < 1e-6);
        end

        function test_matyas
            solver = cv.ConjGradSolver('Function', ...
                struct('dims',2, 'fun','matyas', 'gradfun','matyasGrad'));
            [x,f] = solver.minimize([10, -10]);
            etalon_x = [0, 0];
            assert(norm(x-etalon_x) < 1e-6);
        end

        function test_beale
            solver = cv.ConjGradSolver('Function', ...
                struct('dims',2, 'fun','beale', 'gradfun','bealeGrad'));
            [x,f] = solver.minimize([2, 0]);
            etalon_x = [3, 0.5];
            %assert(norm(x-etalon_x) < 1e-6);
            warning('mexopencv:warn', '[DISABLED] fails to find solution.')
        end

        function test_error_1
            try
                cv.ConjGradSolver('foo', 'bar');
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
function grad = rosenbrockGrad(x)
    a = 1;
    b = 100;
    grad = [
        2*(x(1)-a)-4*b*(x(2)-x(1)^2)*x(1), ...
        2*b*(x(2)-x(1)^2)
    ];
end

% Sphere function
function f = sphere(x)
    f = sum(x.^2);
end
function grad = sphereGrad(x)
    grad = 2.*x;
end

% Booth's function
function f = booth(x)
    f = (x(1)+2*x(2)-7)^2 + (2*x(1)+x(2)-5)^2;
end
function grad = boothGrad(x)
    grad = [
        10*x(1) + 8*x(2) - 34, ...
        8*x(1) + 10*x(2) - 38
    ];
end

% Matyas function
function f = matyas(x)
    f = 0.26*(x(1)^2+x(2)^2) - 0.48*x(1)*x(2);
end
function grad = matyasGrad(x)
    grad = [
        0.52*x(1) - 0.48*x(2), ...
        0.52*x(2) - 0.48*x(1)
    ];
end

% Beale's function
%  syms f x y
%  f(x,y) = (1.5-x-x*y)^2 + (2.25-x+x*y^2)^2 + (2.625-x+x*y^3)^2
%  [diff(f,x), diff(f,y)]
function f = beale(x)
    f = (1.5 - x(1) - x(1)*x(2))^2 + ...
        (2.25 - x(1) + x(1)*x(2)^2)^2 + ...
        (2.625 - x(1) + x(1)*x(2)^3)^2;
end
function grad = bealeGrad(x)
    grad = [
        2*(x(2) + 1)*(x(1) + x(1)*x(2) - 1.5) + ...
        2*(x(2)^2 - 1)*(x(1)*x(2)^2 - x(1) + 2.25) + ...
        2*(x(2)^3 - 1)*(x(1)*x(2)^3 - x(1) + 2.625), ...
        2*x(1)*(x(1) + x(1)*x(2) - 1.5) + ...
        4*x(1)*x(2)*(x(1)*x(2)^2 - x(1) + 2.25) + ...
        6*x(1)*x(2)^2*(x(1)*x(2)^3 - x(1) + 2.625)
    ];
end

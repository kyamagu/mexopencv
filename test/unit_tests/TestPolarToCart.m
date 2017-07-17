classdef TestPolarToCart
    %TestPolarToCart

    methods (Static)
        function test_radians
            theta = linspace(0, pi, 10);
            rho = rand(size(theta));
            [x, y] = cv.polarToCart(rho, theta);
            validateattributes(x, {class(theta)}, {'size',size(theta)});
            validateattributes(y, {class(theta)}, {'size',size(theta)});

            theta = single(theta);
            rho = single(rho);
            [x, y] = cv.polarToCart(rho, theta);
            validateattributes(x, {class(theta)}, {'size',size(theta)});
            validateattributes(y, {class(theta)}, {'size',size(theta)});
        end

        function test_degrees
            theta = linspace(0, 180, 10);
            rho = rand(size(theta));
            [x, y] = cv.polarToCart(rho, theta, 'Degrees',true);
            validateattributes(x, {class(theta)}, {'size',size(theta)});
            validateattributes(y, {class(theta)}, {'size',size(theta)});
        end

        function test_error_argnum
            try
                cv.polarToCart();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestCartToPolar
    %TestCartToPolar

    methods (Static)
        function test_radians
            x = randn(5,6);
            y = randn(5,6);
            [rho, theta] = cv.cartToPolar(x, y);
            validateattributes(rho, {class(x)}, {'size',size(x)});
            validateattributes(theta, {class(x)}, {'size',size(x)});

            x = single(x);
            y = single(y);
            [rho, theta] = cv.cartToPolar(x, y);
            validateattributes(rho, {class(x)}, {'size',size(x)});
            validateattributes(theta, {class(x)}, {'size',size(x)});
        end

        function test_degrees
            x = randn(5,6);
            y = randn(5,6);
            [rho, theta] = cv.cartToPolar(x, y, 'Degrees',true);
            validateattributes(rho, {class(x)}, {'size',size(x)});
            validateattributes(theta, {class(x)}, {'size',size(x)});
        end

        function test_error_argnum
            try
                cv.cartToPolar();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

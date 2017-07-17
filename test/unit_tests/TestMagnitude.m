classdef TestMagnitude
    %TestMagnitude

    methods (Static)
        function test_1
            x = randn(5,6);
            y = randn(5,6);
            mag = cv.magnitude(x, y);
            validateattributes(mag, {class(x)}, {'size',size(x)});

            x = single(x);
            y = single(y);
            mag = cv.magnitude(x, y);
            validateattributes(mag, {class(x)}, {'size',size(x)});
        end

        function test_error_argnum
            try
                cv.magnitude();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

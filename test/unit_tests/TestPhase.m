classdef TestPhase
    %TestPhase

    methods (Static)
        function test_radians
            x = randn(5,6);
            y = randn(5,6);
            ang = cv.phase(x, y);
            validateattributes(ang, {class(x)}, {'size',size(x)});

            x = single(x);
            y = single(y);
            ang = cv.phase(x, y);
            validateattributes(ang, {class(x)}, {'size',size(x)});
        end

        function test_degrees
            x = randn(5,6);
            y = randn(5,6);
            ang = cv.phase(x, y, 'Degrees',true);
            validateattributes(ang, {class(x)}, {'size',size(x)});
        end

        function test_error_argnum
            try
                cv.phase();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

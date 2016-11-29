classdef TestIsContourConvex
    %TestIsContourConvex

    properties (Constant)
        pts = [0 0; 1 0; 2 2; 3 3; 3 4];
    end

    methods (Static)
        function test_1
            b = cv.isContourConvex(TestIsContourConvex.pts);
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_2
            b = cv.isContourConvex(num2cell(TestIsContourConvex.pts,2));
            validateattributes(b, {'logical'}, {'scalar'});
        end

        function test_error_argnum
            try
                cv.isContourConvex();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

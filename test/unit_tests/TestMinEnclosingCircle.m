classdef TestMinEnclosingCircle
    %TestMinEnclosingCircle
    properties (Constant)
        p = [0 0; 1 0; 2 2; 3 3; 3 4];
    end

    methods (Static)
        function test_1
            [c,r] = cv.minEnclosingCircle(TestMinEnclosingCircle.p);
            validateattributes(c, {'numeric'}, {'vector', 'numel',2});
            validateattributes(r, {'numeric'}, {'scalar'});
        end

        function test_2
            [c,r] = cv.minEnclosingCircle(num2cell(TestMinEnclosingCircle.p,2));
            validateattributes(c, {'numeric'}, {'vector', 'numel',2});
            validateattributes(r, {'numeric'}, {'scalar'});
        end

        function test_error_1
            try
                cv.minEnclosingCircle();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestMinEnclosingTriangle
    %TestMinEnclosingTriangle
    properties (Constant)
        p = [0 0; 1 0; 2 2; 3 3; 3 4];
    end

    methods (Static)
        function test_1
            [tr,a] = cv.minEnclosingTriangle(TestMinEnclosingTriangle.p);
            validateattributes(tr, {'cell'}, {'vector', 'numel',3});
            cellfun(@(t) validateattributes(t, {'numeric'}, {'vector', 'numel',2}), tr);
            validateattributes(a, {'numeric'}, {'scalar'});
        end

        function test_2
            [tr,a] = cv.minEnclosingTriangle(num2cell(TestMinEnclosingTriangle.p,2));
            validateattributes(tr, {'cell'}, {'vector', 'numel',3});
            cellfun(@(t) validateattributes(t, {'numeric'}, {'vector', 'numel',2}), tr);
            validateattributes(a, {'numeric'}, {'scalar'});
        end

        function test_error_1
            try
                cv.minEnclosingTriangle();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

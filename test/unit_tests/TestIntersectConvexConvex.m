classdef TestIntersectConvexConvex
    %TestIntersectConvexConvex
    properties (Constant)
        p1 = [0 0; 0 1; 1 1; 1 0];
        p2 = [-0.5 0.2; 0.5 1.2; 1.2 0.3];
    end

    methods (Static)
        function test_1
            [p12,a] = cv.intersectConvexConvex(...
                TestIntersectConvexConvex.p1, ...
                TestIntersectConvexConvex.p2);
            validateattributes(p12, {'cell'}, {'vector'});
            cellfun(@(pt) validateattributes(pt, {'numeric'}, {'vector', 'numel',2}), p12);
            validateattributes(a, {'numeric'}, {'scalar', 'real'});
        end

        function test_2
            [p12,a] = cv.intersectConvexConvex(...
                num2cell(TestIntersectConvexConvex.p1,2), ...
                num2cell(TestIntersectConvexConvex.p2,2));
            validateattributes(p12, {'cell'}, {'vector'});
            cellfun(@(pt) validateattributes(pt, {'numeric'}, {'vector', 'numel',2}), p12);
            validateattributes(a, {'numeric'}, {'scalar', 'real'});
        end

        function test_3
            [p12,a] = cv.intersectConvexConvex(...
                TestIntersectConvexConvex.p1, ...
                TestIntersectConvexConvex.p2, ...
                'HandleNested',false);
        end

        function test_error_1
            try
                cv.intersectConvexConvex();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

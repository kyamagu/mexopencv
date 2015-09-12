classdef TestRotatedRectangleIntersection
    %TestRotatedRectangleIntersection

    methods (Static)
        function test_0
            rect1 = struct('center',rand(1,2), 'size',rand(1,2), 'angle',rand());
            rect2 = struct('center',rand(1,2), 'size',rand(1,2), 'angle',rand());
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            validateattributes(intersection, {'cell'}, {'vector'});
            cellfun(@(pt) validateattributes(pt, {'numeric'}, {'vector', 'numel',2}), intersection);
            validateattributes(result, {'char'}, {'row'});
            assert(ismember(result, {'None', 'Partial', 'Full'}));
        end

        function test_1
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[1,1], 'size',[2,2], 'angle',0);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 4);
            assert(strcmp(result, 'Partial'));
        end

        function test_2
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[1,1], 'size',[2,2], 'angle',45);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 3);
            assert(strcmp(result, 'Partial'));
        end

        function test_3
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 4);
            assert(strcmp(result, 'Full'));
        end

        function test_4
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[0,0], 'size',[2,2], 'angle',45);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 8);
            assert(strcmp(result, 'Partial'));
        end

        function test_5
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[0,0], 'size',[1,3], 'angle',0);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 4);
            assert(strcmp(result, 'Partial'));
        end

        function test_6
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[0,0], 'size',[1,1], 'angle',0);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 4);
            assert(strcmp(result, 'Full'));
        end

        function test_7
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[2,2], 'size',[2,2], 'angle',0);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 1);
            assert(strcmp(result, 'Partial'));
        end

        function test_8
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[2,0], 'size',[2,4], 'angle',0);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(numel(intersection) == 2);
            assert(strcmp(result, 'Partial'));
        end

        function test_9
            rect1 = struct('center',[0,0], 'size',[2,2], 'angle',0);
            rect2 = struct('center',[5,5], 'size',[2,2], 'angle',0);
            [intersection,result] = cv.rotatedRectangleIntersection(rect1, rect2);
            assert(isempty(intersection));
            assert(strcmp(result, 'None'));
        end

        function test_error_1
            try
                cv.rotatedRectangleIntersection();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

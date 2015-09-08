classdef TestClipLine
    %TestClipLine

    methods (Static)
        function test_1
            [inside,p1,p2] = cv.clipLine([64,64], [2,60], [60,2]);
            assert(inside);
            validateattributes(inside, {'logical'}, {'scalar'});
            validateattributes(p1, {'numeric'}, {'vector', 'numel',2});
            validateattributes(p2, {'numeric'}, {'vector', 'numel',2});
        end

        function test_2
            [inside,p1,p2] = cv.clipLine([64,64], [65,80], [80,65]);
            assert(~inside);
            validateattributes(inside, {'logical'}, {'scalar'});
            validateattributes(p1, {'numeric'}, {'vector', 'numel',2});
            validateattributes(p2, {'numeric'}, {'vector', 'numel',2});
        end

        function test_3
            [inside,p1,p2] = cv.clipLine([10,10,64,64], [65,80], [80,65]);
            assert(inside);
            validateattributes(inside, {'logical'}, {'scalar'});
            validateattributes(p1, {'numeric'}, {'vector', 'numel',2});
            validateattributes(p2, {'numeric'}, {'vector', 'numel',2});
        end

        function test_error_1
            try
                cv.clipLine();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

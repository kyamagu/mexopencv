classdef TestBoundingRect
    %TestBoundingRect

    methods (Static)
        function test_1
            curve = {[0 0], [1 0], [2 2], [3 3], [3 4]};
            rct = cv.boundingRect(curve);
            validateattributes(rct, {'numeric'}, {'vector', 'numel',4});
        end

        function test_2
            curve = int32([0 0; 1 0; 2 2; 3 3; 3 4]);
            rct = cv.boundingRect(curve);
            validateattributes(rct, {'numeric'}, {'vector', 'numel',4});
        end

        function test_3
            curve = single([0 0; 1 0; 2 2; 3 3; 3 4]);
            rct = cv.boundingRect(curve);
            validateattributes(rct, {'numeric'}, {'vector', 'numel',4});
        end

        function test_4
            [X,Y] = ndgrid((1:50)-25,(1:50)-25);
            mask = logical((X.^2 + Y.^2) < 15^2);  % circular mask
            rct = cv.boundingRect(mask);
            validateattributes(rct, {'numeric'}, {'vector', 'numel',4});
        end

        function test_5
            mask = cv.circle(zeros(50,'uint8'), [25 25], 15, ...
                'Color',255, 'Thickness','Filled');
            rct = cv.boundingRect(mask);
            validateattributes(rct, {'numeric'}, {'vector', 'numel',4});
        end

        function test_error_argnum
            try
                cv.boundingRect();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

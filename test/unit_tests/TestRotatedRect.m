classdef TestRotatedRect
    %TestRotatedRect

    methods (Static)
        function test_RotatedRect_from3points
            pts = {[10,10], [10,20], [20,20]};
            rrect = cv.RotatedRect.from3points(pts{:});
            validateattributes(rrect, {'struct'}, {'scalar'});
            assert(all(ismember({'center','size','angle'}, fieldnames(rrect))));
        end

        function test_RotatedRect_points
            rrect = struct('center',[10,20], 'size',[5,6], 'angle',30);
            pts = cv.RotatedRect.points(rrect);
            validateattributes(pts, {'numeric'}, {'size',[4 2]});
        end

        function test_RotatedRect_boundingRect
            rrect = struct('center',[10,20], 'size',[5,6], 'angle',30);

            rect = cv.RotatedRect.boundingRect(rrect);
            validateattributes(rect, {'numeric'}, {'vector', 'numel',4, 'integer'});

            rect = cv.RotatedRect.boundingRect2f(rrect);
            validateattributes(rect, {'numeric'}, {'vector', 'numel',4, 'real'});
        end
    end

end

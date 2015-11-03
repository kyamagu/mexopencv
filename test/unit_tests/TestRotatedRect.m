classdef TestRotatedRect
    %TestRotatedRect

    methods (Static)
        function test_RotatedRect_points
            rrect = struct('center',[10,20], 'size',[5,6], 'angle',30);
            pts = cv.RotatedRect.points(rrect);
            assert(ismatrix(pts) && isequal(size(pts), [4 2]));
        end

        function test_RotatedRect_boundingRect
            rrect = struct('center',[10,20], 'size',[5,6], 'angle',30);
            rect = cv.RotatedRect.boundingRect(rrect);
            assert(isvector(rect) && numel(rect)==4);
        end

        function test_RotatedRect_from3points
            pts = {[10,10], [10,20], [20,20]};
            rrect = cv.RotatedRect.from3points(pts{:});
            assert(isstruct(rrect) && isscalar(rrect));
            assert(all(ismember({'center','size','angle'}, fieldnames(rrect))));
        end
    end

end

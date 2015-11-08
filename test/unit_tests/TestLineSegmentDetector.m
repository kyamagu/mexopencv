classdef TestLineSegmentDetector
    %TestLineSegmentDetector

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root,'test','img001.jpg'), 'Flags',0);
            lsd = cv.LineSegmentDetector('Refine','Advanced');

            [lines, width, prec, nfa] = lsd.detect(img);
            validateattributes(lines, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',4, 'real'}), lines);
            validateattributes(width, {'numeric'}, {'vector', 'numel',numel(lines)});
            validateattributes(prec, {'numeric'}, {'vector', 'numel',numel(lines)});
            validateattributes(nfa, {'numeric'}, {'vector', 'numel',numel(lines)});

            out = lsd.drawSegments(img, lines);
            validateattributes(out, {class(img)}, {'3d', 'size',[size(img) 3]});
        end

        function test_2
            img = cv.imread(fullfile(mexopencv.root,'test','img001.jpg'), 'Flags',0);
            lsd1 = cv.LineSegmentDetector('Refine','Standard');
            lsd2 = cv.LineSegmentDetector('Refine','None');
            lines1 = lsd1.detect(img);
            lines2 = lsd2.detect(img);
            [comp,c] = lsd1.compareSegments([size(img,2) size(img,1)], lines1, lines2);
            validateattributes(comp, {class(img)}, {'3d', 'size',[size(img) 3]});
            validateattributes(c, {'numeric'}, {'scalar', 'integer', 'nonnegative'});
        end
    end

end

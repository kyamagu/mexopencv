classdef TestLineSegmentDetector
    %TestLineSegmentDetector
    properties (Constant)
    end

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root,'test','img001.jpg'), 'Flags',0);
            lsd = cv.LineSegmentDetector('Refine','Standard');
            [lines, width, prec, nfa] = lsd.detect(img);
            out = lsd.drawSegments(img, lines);
        end

        function test_2
            img = cv.imread(fullfile(mexopencv.root,'test','img001.jpg'), 'Flags',0);
            lsd1 = cv.LineSegmentDetector('Refine','Standard');
            lsd2 = cv.LineSegmentDetector('Refine','None');
            lines1 = lsd1.detect(img);
            lines2 = lsd2.detect(img);
            [comp,c] = lsd1.compareSegments([size(img,2) size(img,1)], lines1, lines2);
        end
    end

end

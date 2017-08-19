classdef TestRect
    %TestRect

    methods (Static)
        function test_1
            pt1 = [2 3];
            pt2 = [6 8];
            rect = cv.Rect.from2points(pt1, pt2);
            validateattributes(rect, {'numeric'}, {'vector', 'numel',4});
            assert(isequal(rect, [pt1 pt2-pt1]));

            pt = cv.Rect.tl(rect);
            validateattributes(pt, {'numeric'}, {'vector', 'numel',2});
            assert(isequal(pt, pt1));

            pt = cv.Rect.br(rect);
            validateattributes(pt, {'numeric'}, {'vector', 'numel',2});
            assert(isequal(pt, pt2));

            sz = cv.Rect.size(rect);
            validateattributes(sz, {'numeric'}, {'vector', 'numel',2});
            assert(isequal(sz, pt2-pt1));

            a = cv.Rect.area(rect);
            validateattributes(a, {'numeric'}, {'scalar'});
            assert(isequal(a, prod(pt2-pt1)));

            r = cv.Rect.adjustPosition(rect, [1 2]);
            validateattributes(r, {'numeric'}, {'vector', 'numel',4});
            assert(isequal(r, rect + [1 2 0 0]));

            r = cv.Rect.adjustSize(rect, [1 2]);
            validateattributes(r, {'numeric'}, {'vector', 'numel',4});
            assert(isequal(r, rect + [0 0 1 2]));
        end

        function test_Rect_contains
            rect = [5 5 10 20];

            pt = [0 0];    % outside
            b = cv.Rect.contains(rect, pt);
            validateattributes(b, {'logical'}, {'scalar'});
            assert(b == false);

            pt = [10 10];  % inside
            b = cv.Rect.contains(rect, pt);
            validateattributes(b, {'logical'}, {'scalar'});
            assert(b == true);

            pt = [5 5];    % on edge
            b = cv.Rect.contains(rect, pt);
            validateattributes(b, {'logical'}, {'scalar'});
            assert(b == true);
        end

        function test_intersect_union
            r1 = [150 80 100 100];
            r2 = r1 + 50;

            r = cv.Rect.intersect(r1, r2);
            validateattributes(r, {'numeric'}, {'vector', 'numel',4});

            r = cv.Rect.union(r1, r2);
            validateattributes(r, {'numeric'}, {'vector', 'numel',4});
        end

        function test_crop
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            r = [175 175 225 225];

            roi = cv.Rect.crop(img, r);
            validateattributes(roi, {class(img)}, {'size',[r(3:4) size(img,3)]});

            roi = flipud(roi);
            out = cv.Rect.crop(img, r, roi);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end
    end

end

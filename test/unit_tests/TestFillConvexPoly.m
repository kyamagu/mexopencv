classdef TestFillConvexPoly
    %TestFillConvexPoly

    methods (Static)
        function test_draw_filled_polygon
            % white background image
            img = zeros([128,128,3], 'uint8') + 255;

            % fill a poly in red with anti-aliased lines
            pts = {[50,50], [50,70], [70,70]};
            out = cv.fillConvexPoly(img, pts, ...
                'Color',[255,0,0], 'LineType','AA');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_grayscale
            % intensity image of type double
            img = zeros(10,10);
            pts = {[2 2], [2 7], [7 7]};
            out = cv.fillConvexPoly(img, pts, 'Color',0.5);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_numeric_points
            img = zeros(10,10);
            pts = [2 2; 2 7; 7 7];
            out = cv.fillConvexPoly(img, pts, 'Color',0.5);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.fillConvexPoly();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

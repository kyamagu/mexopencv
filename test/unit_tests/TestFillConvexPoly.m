classdef TestFillConvexPoly
    %TestFillConvexPoly
    properties (Constant)
    end

    methods (Static)
        function test_draw_filled_polygon
            % white background image
            im = zeros([128,128,3], 'uint8') + 255;

            % fill a poly in red with anti-aliased lines
            pts = {[50,50], [50,70], [70,70]};
            out = cv.fillConvexPoly(im, pts, ...
                'Color',[255,0,0], 'LineType','AA');
        end

        function test_grayscale
            % intensity image of type double
            img = zeros(10,10);
            pts = {[2 2], [2 7], [7 7]};
            img = cv.fillConvexPoly(img, pts, 'Color',0.5);
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

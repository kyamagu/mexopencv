classdef TestFillPoly
    %TestFillPoly

    methods (Static)
        function test_draw_filled_polygon
            % white background image
            img = zeros([128,128,3], 'uint8') + 255;

            % fill a single polygon in red with anti-aliased lines
            pts = {{[50,50], [50,70], [70,70]}};
            out = cv.fillPoly(img, pts, 'Color',[255,0,0], 'LineType','AA');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_draw_filled_polygons
            % white background image
            img = zeros([128,128,3], 'uint8') + 255;

            % fill multiple polygons in red with anti-aliased lines
            pts = {{[50,50], [50,70], [70,70]}, {[60,50], [70,50], [70,60]}};
            out = cv.fillPoly(img, pts, 'Color',[255,0,0], 'LineType','AA');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_grayscale
            % intensity image of type double
            img = zeros(10,10);
            pts = {{[0 0], [0 4], [4 4]}, {[6 5], [7 5], [7 6], [5 6]}};
            out = cv.fillPoly(img, pts, 'Color',0.5);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_cell_numeric
            % cell array of Nx2 matrices
            img = zeros(10,10);
            pts = {[0 0; 0 4; 4 4], [6 5; 7 5; 7 6; 5 6]};
            out = cv.fillPoly(img, pts, 'Color',0.5);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.fillPoly();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

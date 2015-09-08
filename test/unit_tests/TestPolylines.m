classdef TestPolylines
    %TestPolylines

    methods (Static)
        function test_draw_polyline
            % white background image
            im = zeros([128,128,3], 'uint8') + 255;

            % trace a single polyline in red with anti-aliased lines
            pts = {{[50,50], [50,70], [70,70]}};
            out = cv.polylines(im, pts, 'Closed',true, ...
                'Color',[255,0,0], 'LineType','AA', 'Thickness',2);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_draw_polylines
            % white background image
            im = zeros([128,128,3], 'uint8') + 255;

            % trace multiple polylines in red with anti-aliased lines
            pts = {{[50,50], [50,70], [70,70]}, {[60,50], [70,50], [70,60]}};
            out = cv.polylines(im, pts, 'Closed',true, ...
                'Color',[255,0,0], 'LineType','AA', 'Thickness',2);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_grayscale
            % intensity image of type double
            im = zeros(10,10);
            pts = {{[0 0], [0 4], [4 4]}, {[6 5], [7 5], [7 6], [5 6]}};
            out = cv.polylines(im, pts, 'Color',0.5);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_cell_numeric
            % cell array of Nx2 matrices
            im = zeros(10,10);
            pts = {[0 0; 0 4; 4 4], [6 5; 7 5; 7 6; 5 6]};
            out = cv.polylines(im, pts, 'Color',0.5);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_error_1
            try
                cv.polylines();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestPlot2d
    %TestPlot2d

    methods (Static)
        function test_y
            y = cumsum(rand(100,1) - 0.5);
            p = cv.Plot2d(y);
            p.PlotSize = [640 480];
            p.PlotLineWidth = 2;
            out = p.render();
            validateattributes(out, {'uint8'}, {'size',[480 640 3]});
        end

        function test_xy
            x = linspace(-2*pi, 2*pi, 100);
            y = sin(x);
            p = cv.Plot2d(x,y);
            p.PlotSize = [400 300];
            p.PlotLineColor = [255 255 0];
            out = p.render();
            validateattributes(out, {'uint8'}, {'size',[300 400 3]});
        end

        function test_error_argnum
            try
                cv.Plot2d();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

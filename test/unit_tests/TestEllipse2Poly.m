classdef TestEllipse2Poly
    %TestEllipse2Poly

    methods (Static)
        function test_1
            pts = cv.ellipse2Poly([64,64], [20,10]);
            validateattributes(pts, {'numeric'}, ...
                {'2d', 'size',[NaN 2], 'integer'});
        end

        function test_2
            pts = cv.ellipse2Poly([64,64], [20,10], 'Angle',30, ...
                'StartAngle',15, 'EndAngle',200, 'Delta',2);
            validateattributes(pts, {'numeric'}, ...
                {'2d', 'size',[NaN 2], 'integer'});
        end

        function test_3
            pts = cv.ellipse2Poly([64,64], [20,10], 'DoublePrecision',true);
            validateattributes(pts, {'numeric'}, ...
                {'2d', 'size',[NaN 2], 'real'});
        end

        function test_error_argnum
            try
                cv.ellipse2Poly();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

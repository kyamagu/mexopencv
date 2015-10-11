classdef TestEllipse2Poly
    %TestEllipse2Poly

    methods (Static)
        function test_1
            pts = cv.ellipse2Poly([64,64], [20,10]);
            validateattributes(pts, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',2, 'integer'}), pts);
        end

        function test_2
            pts = cv.ellipse2Poly([64,64], [20,10], 'Angle',30, ...
                'StartAngle',15, 'EndAngle',200, 'Delta',2);
            validateattributes(pts, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',2, 'integer'}), pts);
        end

        function test_error_1
            try
                cv.ellipse2Poly();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

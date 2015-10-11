classdef TestConvexityDefects
    %TestConvexityDefects

    methods (Static)
        function test_input_1
            % cell array
            points = {[0 0], [1 0], [2 2], [3 3], [3 4]};
            hull = cv.convexHull(points, 'ReturnPoints',false);
            defects = cv.convexityDefects(points, hull);
            validateattributes(defects, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'}), defects);
        end

        function test_input_2
            % numeric matrix
            points = [0 0; 1 0; 2 2; 3 3; 3 4];
            hull = cv.convexHull(points, 'ReturnPoints',false);
            defects = cv.convexityDefects(points, hull);
            validateattributes(defects, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',4, 'integer'}), defects);
        end

        function test_error_1
            try
                cv.convexHull();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

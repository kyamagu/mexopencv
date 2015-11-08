classdef TestConvexHull
    %TestConvexHull

    methods (Static)
        function test_input_1
            % cell array
            points = {[0 0], [1 1], [2 2], [3 3], [4 4]};
            hull = cv.convexHull(points);
        end

        function test_input_2
            % Nx2 matrix
            points = [0 0; 1 0; 2 2; 3 3; 3 4];
            hull = cv.convexHull(points);
        end

        function test_input_3
            % 1xNx2 matrix
            points = shiftdim([0 0; 1 0; 2 2; 3 3; 3 4], -1);
            hull = cv.convexHull(points);
        end

        function test_input_4
            % Nx1x2 matrix
            points = permute([0 0; 1 0; 2 2; 3 3; 3 4], [1 3 2]);
            hull = cv.convexHull(points);
        end

        function test_type_1
            points = single([0 0; 1 0; 2 2; 3 3; 3 4]);
            hull = cv.convexHull(points);
        end

        function test_option_1
            points = [0 0; 1 0; 2 2; 3 3; 3 4];
            hull = cv.convexHull(points, 'Clockwise',false);
            hull = cv.convexHull(points, 'Clockwise',true);
        end

        function test_output_1
            points = int32([0 0; 1 0; 2 2; 3 3; 3 4]);

            hull = cv.convexHull(points, 'ReturnPoints',true);
            validateattributes(hull, {'numeric'}, {'2d', 'ncols',2});
            assert(isa(hull, class(points)));

            hull = cv.convexHull(points, 'ReturnPoints',false);
            validateattributes(hull, {'int32'}, {'vector', 'nonnegative'});
        end

        function test_output_2
            points = num2cell(int32([0 0; 1 0; 2 2; 3 3; 3 4]),2);

            hull = cv.convexHull(points, 'ReturnPoints',true);
            validateattributes(hull, {'cell'}, {'vector'});
            assert(all(cellfun(@numel, hull) == 2));

            hull = cv.convexHull(points, 'ReturnPoints',false);
            validateattributes(hull, {'int32'}, {'vector', 'nonnegative'});
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

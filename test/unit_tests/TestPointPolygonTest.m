classdef TestPointPolygonTest
    %TestPointPolygonTest

    methods (Static)
        function test_contour_matrix
            cntr = [0 0; 1 0; 2 2; 3 3; 3 4];
            b = cv.pointPolygonTest(cntr, [2.3 2.4]);
            validateattributes(b, {'double'}, {'scalar'});

            % purely-integer points (both contour and query)
            b = cv.pointPolygonTest(int32(cntr), [2 2]);
            validateattributes(b, {'double'}, {'scalar'});
        end

        function test_contour_cellarray
            cntr = {[0 0], [1 0], [2 2], [3 3], [3 4]};
            b = cv.pointPolygonTest(cntr, [2.3 2.4]);
            validateattributes(b, {'double'}, {'scalar'});
        end

        function test_measure_dist
            cntr = [0 0; 1 0; 2 2; 3 3; 3 4];

            b = cv.pointPolygonTest(cntr, [2.3,2.4], 'MeasureDist',true);
            validateattributes(b, {'double'}, {'scalar', 'real'});

            b = cv.pointPolygonTest(cntr, [2.3,2.4], 'MeasureDist',false);
            validateattributes(b, {'double'}, {'scalar', 'integer'});
            assert(b == 0 || b == 1 || b == -1);
        end

        function test_error_argnum
            try
                cv.pointPolygonTest();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

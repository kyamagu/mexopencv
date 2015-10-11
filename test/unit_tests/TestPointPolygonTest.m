classdef TestPointPolygonTest
    %TestPointPolygonTest

    methods (Static)
        function test_1
            contour = [0 0; 1 0; 2 2; 3 3; 3 4];
            b = cv.pointPolygonTest(contour, [2.3 2.4]);
            validateattributes(b, {'double'}, {'scalar'});
        end

        function test_2
            contour = {[0 0], [1 0], [2 2], [3 3], [3 4]};
            b = cv.pointPolygonTest(contour, [2.3 2.4]);
            validateattributes(b, {'double'}, {'scalar'});
        end

        function test_3
            contour = [0 0; 1 0; 2 2; 3 3; 3 4];

            b = cv.pointPolygonTest(contour, [2.3,2.4], 'MeasureDist',true);
            validateattributes(b, {'double'}, {'scalar', 'real'});

            b = cv.pointPolygonTest(contour, [2.3,2.4], 'MeasureDist',false);
            validateattributes(b, {'double'}, {'scalar', 'integer'});
            assert(b == 0 || b == 1 || b == -1);
        end

        function test_error_1
            try
                cv.pointPolygonTest();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

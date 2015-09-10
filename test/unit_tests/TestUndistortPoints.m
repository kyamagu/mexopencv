classdef TestUndistortPoints
    %TestUndistortPoints
    properties (Constant)
        pts = [0 0; 0 1; 3 4; 5 6];
    end

    methods (Static)
        function test_Nx2
            pts = TestUndistortPoints.pts;
            result = cv.undistortPoints(pts, eye(3), []);
            validateattributes(result, {class(pts)}, {'size',size(pts)})
            assert(isequal(result, pts));
        end

        function test_Nx1x2
            pts = permute(TestUndistortPoints.pts, [1 3 2]);
            result = cv.undistortPoints(pts, eye(3), []);
            validateattributes(result, {class(pts)}, {'size',size(pts)})
            assert(isequal(result, pts));
        end

        function test_1xNx2
            pts = permute(TestUndistortPoints.pts, [3 1 2]);
            result = cv.undistortPoints(pts, eye(3), []);
            validateattributes(result, {class(pts)}, {'size',size(pts)})
            assert(isequal(result, pts));
        end

        function test_single
            pts = single(TestUndistortPoints.pts);
            result = cv.undistortPoints(pts, eye(3), []);
            validateattributes(result, {class(pts)}, {'size',size(pts)})
            assert(isequal(result, pts));
        end

        function test_options
            pts = single(TestUndistortPoints.pts);
            result = cv.undistortPoints(pts, eye(3), zeros(1,4), ...
                'R',eye(3), 'P',eye(3));
            validateattributes(result, {class(pts)}, {'size',size(pts)})
            assert(isequal(result, pts));
        end

        function test_error_1
            try
                cv.undistortPoints();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

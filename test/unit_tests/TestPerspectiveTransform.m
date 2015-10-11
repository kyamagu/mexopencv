classdef TestPerspectiveTransform
    %TestPerspectiveTransform

    methods (Static)
        function test_2d_numeric
            M = [cos(pi/4) sin(pi/4) 0 ; ...
                -sin(pi/4) cos(pi/4) 0 ; ...
                        0         0  1];
            % Nx2x1
            src = randn(10,2);
            dst = cv.perspectiveTransform(src, M);
            validateattributes(dst, {class(src)}, {'size',size(src)});
            % 1xNx2
            src = shiftdim(randn(10,2), -1);
            dst = cv.perspectiveTransform(src, M);
            validateattributes(dst, {class(src)}, {'size',size(src)});
            % Nx1x2
            src = permute(randn(10,2), [1 3 2]);
            dst = cv.perspectiveTransform(src, M);
            validateattributes(dst, {class(src)}, {'size',size(src)});
        end

        function test_3d_numeric
            M = eye(4);
            % Nx3
            src = randn(10,3);
            dst = cv.perspectiveTransform(src, M);
            validateattributes(dst, {class(src)}, {'size',size(src)});
            % 1xNx3
            src = permute(randn(10,3), [3 1 2]);
            dst = cv.perspectiveTransform(src, M);
            validateattributes(dst, {class(src)}, {'size',size(src)});
            % Nx1x3
            src = permute(randn(10,3), [1 3 2]);
            dst = cv.perspectiveTransform(src, M);
            validateattributes(dst, {class(src)}, {'size',size(src)});
        end

        function test_2d_cell
            M = eye(3);
            pts = num2cell(randn(10,2), 2);
            dst = cv.perspectiveTransform(pts, M);
            validateattributes(dst, {'cell'}, {'vector', 'numel',numel(pts)});
            cellfun(@(pt) validateattributes(pt, {'numeric'}, ...
                {'vector', 'numel',2}), dst);
        end

        function test_3d_cell
            M = eye(4);
            pts = num2cell(randn(10,3), 2);
            dst = cv.perspectiveTransform(pts, M);
            cellfun(@(pt) validateattributes(pt, {'numeric'}, ...
                {'vector', 'numel',3}), dst);
        end

        function test_error_1
            try
                cv.perspectiveTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

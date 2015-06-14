classdef TestPerspectiveTransform
    %TestPerspectiveTransform
    properties (Constant)
    end

    methods (Static)
        function test_2d_numeric
            M = [cos(pi/4),sin(pi/4),0;...
                -sin(pi/4),cos(pi/4),0;...
                         0,        0,1;];
            src = shiftdim(randn(10,2),-1);
            dst = cv.perspectiveTransform(src,M);
        end

        function test_3d_numeric
            M = eye(4);
            pts = permute(randn(10,3),[1 3 2]);
            dst = cv.perspectiveTransform(pts, M);
        end

        function test_2d_cell
            M = eye(3);
            pts = num2cell(randn(10,2),2);
            dst = cv.perspectiveTransform(pts, M);
        end

        function test_3d_cell
            M = eye(4);
            pts = num2cell(randn(10,3),2);
            dst = cv.perspectiveTransform(pts, M);
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

classdef TestTransform
    %TestTransform
    properties (Constant)
    end

    methods (Static)
        function test_1
            M = [cos(pi/4),sin(pi/4);...
                -sin(pi/4),cos(pi/4);];
            src = shiftdim(randn(10,2),-1);
            dst = cv.transform(src,M);
        end

        function test_2
            % 2x3 affine transformation
            M = [cos(pi/4) -sin(pi/4) 10;
                 sin(pi/4)  cos(pi/4) 20];

            % 2xN matrix of points
            N = 30;
            t = linspace(0, 2*pi, N);
            src = [100 + 30*cos(t); 100 - 30*sin(t)];

            % OpenCV transform
            src0 = permute(src, [3 2 1]);  % 1xNx2
            dst0 = cv.transform(src0, M);  % 1xNx2
            dst = ipermute(dst0, [3 2 1]); % 2xN

            % compare against MATLAB
            dst2 = M * [src;ones(1,N)];    % 2xN = (2x3) * (3xN)
            assert(norm(dst-dst2)<1e-6);
        end

        function test_error_1
            try
                cv.transform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end


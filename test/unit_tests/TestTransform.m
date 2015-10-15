classdef TestTransform
    %TestTransform

    methods (Static)
        function test_1
            M = [cos(pi/4) sin(pi/4) ; ...
                -sin(pi/4) cos(pi/4)];
            src = shiftdim(randn(10,2), -1);
            dst = cv.transform(src, M);
            validateattributes(dst, {class(src)}, {'size',[1 10 2]});
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
            assert(norm(dst-dst2) < 1e-6);
        end

        function test_3
            for d=1:4
                src = rand(30,20,d);
                %---
                %TODO: there's a bug in MxArray::MxArray(Mat) when there are
                % too many mat.channels() (caused by cv::transpose!)
                %mtx = rand(10,d);
                mtx = rand(4,d);
                %---
                dst = cv.transform(src, mtx);
                validateattributes(dst, {class(src)}, ...
                    {'size',[size(src,1) size(src,2) size(mtx,1)]});

                % basically one matrix-multiplication with some reshape/permute!
                dst2 = permute(reshape(permute(...
                    mtx * reshape(permute(src, [3 2 1]), size(src,3), []), ...
                    [2 1 3]), [size(src,2) size(src,1) size(mtx,1)]), [2 1 3]);
                assert(isequal(size(dst), size(dst2)) && all(abs(dst(:) - dst2(:)) < 1e-9));
            end
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

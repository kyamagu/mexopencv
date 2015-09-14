classdef TestRodrigues
    %TestRodrigues

    methods (Static)
        function test_rotation_vec_mat
            M = [cos(pi/4) sin(pi/4) 0 ; ...
                -sin(pi/4) cos(pi/4) 0 ; ...
                        0         0  1];

            % rotation matrix to vector
            dstVec = cv.Rodrigues(M);
            validateattributes(dstVec, {class(M)}, {'vector', 'numel',3});

            % rotation vector to matrix
            dstMat = cv.Rodrigues(dstVec);
            validateattributes(dstMat, {class(M)}, {'2d', 'size',[3 3]});
            assert(norm(dstMat(:)-M(:)) < 1e-9, 'Error is too large');
        end

        function test_single_double_input
            % double precision
            [dst,jacob] = cv.Rodrigues(double(eye(3)));
            validateattributes(dst, {'double'}, {'vector', 'numel',3});
            validateattributes(jacob, {'double'}, {'2d', 'size',[9 3]});

            % single precision
            [dst,jacob] = cv.Rodrigues(single(eye(3)));
            validateattributes(dst, {'single'}, {'vector', 'numel',3});
            validateattributes(jacob, {'single'}, {'2d', 'size',[9 3]});
        end

        function test_vector_matrix_input
            % 3x3 rotation matrix
            dst = cv.Rodrigues(eye(3));
            validateattributes(dst, {'double'}, {'vector', 'numel',3});

            % 3x1/1x3 rotation vector
            dst = cv.Rodrigues(zeros(3,1));
            validateattributes(dst, {'double'}, {'2d', 'size',[3 3]});
            dst = cv.Rodrigues(zeros(1,3));
            validateattributes(dst, {'double'}, {'2d', 'size',[3 3]});
        end

        function test_jacobian
            [~,jacobian] = cv.Rodrigues(eye(3));
            validateattributes(jacobian, {'double'}, {'2d', 'size',[9 3]});

            [~,jacobian] = cv.Rodrigues(zeros(3,1));
            validateattributes(jacobian, {'double'}, {'2d', 'size',[3 9]});

            [~,jacobian] = cv.Rodrigues(zeros(1,3));
            validateattributes(jacobian, {'double'}, {'2d', 'size',[3 9]});
        end

        function test_roundtrip
            src = [0; 0; -pi/4];
            dst = cv.Rodrigues(cv.Rodrigues(src));
            assert(norm(src - dst) < 1e-9);
        end

        function test_error_1
            try
                cv.Rodrigues();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

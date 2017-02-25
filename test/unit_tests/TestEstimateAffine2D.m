classdef TestEstimateAffine2D
    %TestEstimateAffine2D

    methods (Static)
        function test_3points
            % estimate affine transform from three noncollinear 2D points
            N = 3;
            aff0 = rand(2,3)*2 + 1;
            src = rand(N,2) + [1 5; 3 3; 1 3];
            dst = [src ones(N,1)] * aff0';
            [aff, inliers] = cv.estimateAffine2D(src, dst, 'Method','Ransac');
            validateattributes(aff, {'numeric'}, {'real', 'size',[2 3]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
            assert(norm(aff0 - aff, inf) < 1e-3, 'bad accuracy');
            assert(all(inliers), 'all must be inliers');
        end

        function test_input_numeric_Nx2
            N = 5;
            aff0 = rand(2,3)*2 + 1;
            src = rand(N,2);
            dst = [src ones(N,1)] * aff0';
            [aff, inliers] = cv.estimateAffine2D(src, dst);
            validateattributes(aff, {'numeric'}, {'real', 'size',[2 3]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
        end

        function test_input_numeric_1xNx2
            N = 5;
            aff0 = rand(2,3)*2 + 1;
            src = rand(N,2);
            src = permute(src, [3 1 2]);
            dst = cv.transform(src, aff0);
            [aff, inliers] = cv.estimateAffine2D(src, dst);
            validateattributes(aff, {'numeric'}, {'real', 'size',[2 3]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
        end

        function test_input_numeric_Nx1x2
            N = 5;
            aff0 = rand(2,3)*2 + 1;
            src = rand(N,2);
            src = permute(src, [1 3 2]);
            dst = cv.transform(src, aff0);
            [aff, inliers] = cv.estimateAffine2D(src, dst);
            validateattributes(aff, {'numeric'}, {'real', 'size',[2 3]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
        end

        function test_input_cellarray
            N = 5;
            aff0 = rand(2,3)*2 + 1;
            src = rand(N,2);
            dst = [src ones(N,1)] * aff0';
            src = num2cell(src, 2);
            dst = num2cell(dst, 2);
            [aff, inliers] = cv.estimateAffine2D(src, dst);
            validateattributes(aff, {'numeric'}, {'real', 'size',[2 3]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
        end

        function test_error_argnum
            try
                cv.estimateAffine2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

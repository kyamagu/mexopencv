classdef TestEstimateAffine3D
    %TestEstimateAffine3D

    methods (Static)
        function test_4points
            % estimate affine transform from four matching 3-d points
            N = 4;
            aff0 = randn(3,4)*2 + 1;
            src = (rand(N,3) .* [1 1 5; 3 3 5; 1 3 5; 3 1 5]) + 1;
            dst = [src ones(N,1)] * aff0';
            aff = cv.estimateAffine3D(src, dst);
            [aff,inliers,result] = cv.estimateAffine3D(src, dst, ...
                'RansacThreshold',3.0, 'Confidence',0.99);
            validateattributes(aff, {'numeric'}, {'real', 'size',[3 4]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
            validateattributes(result, {'numeric','logical'}, {'scalar'});
            if result > 0
                assert(norm(aff0 - aff) < 1e-3, 'bad accuracy');
            end
        end

        function test_error_argnum
            try
                cv.estimateAffine3D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

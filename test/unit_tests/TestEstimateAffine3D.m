classdef TestEstimateAffine3D
    %TestEstimateAffine3D

    methods (Static)
        function test_4points
            % estimate affine transform from four matching 3-d points
            aff0 = randn(3,4)*2 + 1;
            src = (rand(4,3) .* [1 1 5; 3 3 5; 1 3 5; 3 1 5]) + 1;
            dst = [src ones(4,1)] * aff0';
            aff = cv.estimateAffine3D(src, dst);
            [aff,inliers,result] = cv.estimateAffine3D(src, dst, ...
                'RansacThreshold',3.0, 'Confidence',0.99);
            validateattributes(aff0, {'numeric'}, {'2d', 'real', 'size',[3 4]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',4, 'binary'});
            validateattributes(result, {'numeric','logical'}, {'scalar'});
            if result > 0
                assert(norm(aff0 - aff) < 1e-3, 'bad accuracy');
            end
        end

        function test_error_1
            try
                cv.estimateAffine3D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestEstimateAffinePartial2D
    %TestEstimateAffinePartial2D

    methods (Static)
        function test_2points
            % 2x3 random matrix of affine transformation limited to
            % combinations of translation, rotation, and uniform scaling
            theta = rand()*2*pi;
            scale = rand()*3;
            txy = rand(1,2)*4-2;
            aff0 = [
                cos(theta) * scale, -sin(theta) * scale, txy(1);
                sin(theta) * scale,  cos(theta) * scale, txy(2)
            ];

            % estimate affine transform from two 2D points
            N = 2;
            src = rand(N,2) + [1 5; 3 3];
            dst = [src ones(N,1)] * aff0';
            [aff, inliers] = cv.estimateAffinePartial2D(src, dst, ...
                'Method','Ransac');
            validateattributes(aff, {'numeric'}, {'real', 'size',[2 3]});
            validateattributes(inliers, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
            assert(norm(aff0 - aff, inf) < 1e-3, 'bad accuracy');
            assert(all(inliers), 'all must be inliers');
        end

        function test_error_argnum
            try
                cv.estimateAffinePartial2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

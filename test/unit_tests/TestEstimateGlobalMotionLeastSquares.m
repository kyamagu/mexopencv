classdef TestEstimateGlobalMotionLeastSquares
    %TestEstimateGlobalMotionLeastSquares

    methods (Static)
        function test_1
            im1 = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale1.png'), ...
                'Grayscale',true, 'ReduceScale',2);
            im2 = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale2.png'), ...
                'Grayscale',true, 'ReduceScale',2);
            pt1 = cv.goodFeaturesToTrack(im1, 'MaxCorners',200);
            pt2 = cv.goodFeaturesToTrack(im2, 'MaxCorners',200);
            models = {'Translation', 'TranslationAndScale', 'Rotation', ...
                'Rigid', 'Similarity', 'Affine'};
            for i=1:numel(models)
                [M,rmse] = cv.estimateGlobalMotionLeastSquares(pt1, pt2, ...
                    'MotionModel',models{i});
                validateattributes(M, {'numeric'}, {'2d', 'size',[3 3]});
                validateattributes(rmse, {'numeric'}, {'scalar', 'real'});
            end
        end

        function test_error_argnum
            try
                cv.estimateGlobalMotionLeastSquares();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestFindTransformECC
    %TestFindTransformECC
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','fruits.jpg');
    end

    methods (Static)
        function test_translation
            img = cv.imread(TestFindTransformECC.im, 'Grayscale',true);
            img = cv.resize(img, [216 216]);
            translationGround = [1 0 randi([10 20]);
                                 0 1 randi([10 20])];
            warpedImage = cv.warpAffine(img, translationGround, ...
                'DSize',[200 200], 'Interpolation','Linear', 'WarpInverse',true);
            mapTranslation = [1 0 0; 0 1 0];
            mapTranslation = cv.findTransformECC(warpedImage, img, ...
                'InputWarp',mapTranslation, 'MotionType','Translation', ...
                'Criteria',struct('type','Count+EPS', 'maxCount',50, 'epsilon',-1));
            validateattributes(mapTranslation, {'numeric'}, ...
                {'size',[2 3], 'nonnan', 'finite', '<',1e9});
            assert(norm(mapTranslation - translationGround) < 0.1, 'Accuracy error');
        end

        function test_euclidean
            img = cv.imread(TestFindTransformECC.im, 'Grayscale',true);
            img = cv.resize(img, [216 216]);
            angle = pi/30 + pi*randi([-2 2])/180;
            euclideanGround = [cos(angle) -sin(angle) randi([10 20]);
                               sin(angle)  cos(angle) randi([10 20])];
            warpedImage = cv.warpAffine(img, euclideanGround, ...
                'DSize',[200 200], 'Interpolation','Linear', 'WarpInverse',true);
            mapEuclidean = [1 0 0; 0 1 0];
            mapEuclidean = cv.findTransformECC(warpedImage, img, ...
                'InputWarp',mapEuclidean, 'MotionType','Euclidean', ...
                'Criteria',struct('type','Count+EPS', 'maxCount',50, 'epsilon',-1));
            validateattributes(mapEuclidean, {'numeric'}, ...
                {'size',[2 3], 'nonnan', 'finite', '<',1e9});
            assert(norm(mapEuclidean - euclideanGround) < 0.1, 'Accuracy error');
        end

        function test_affine
            img = cv.imread(TestFindTransformECC.im, 'Grayscale',true);
            img = cv.resize(img, [216 216]);
            affineGround = [1-(rand*0.1-0.05) rand*0.06-0.03 randi([10 20]);
                            rand*0.06-0.03 1-(rand*0.1-0.05) randi([10 20])];
            warpedImage = cv.warpAffine(img, affineGround, ...
                'DSize',[200 200], 'Interpolation','Linear', 'WarpInverse',true);
            mapAffine = [1 0 15; 0 1 15];
            mapAffine = cv.findTransformECC(warpedImage, img, ...
                'InputWarp',mapAffine, 'MotionType','Affine', ...
                'Criteria',struct('type','Count+EPS', 'maxCount',50, 'epsilon',-1));
            validateattributes(mapAffine, {'numeric'}, ...
                {'size',[2 3], 'nonnan', 'finite', '<',1e9});
            assert(norm(mapAffine - affineGround) < 0.1, 'Accuracy error');
        end

        function test_homography
            img = cv.imread(TestFindTransformECC.im, 'Grayscale',true);
            img = cv.resize(img, [216 216]);
            homoGround = [1-(rand*0.1-0.05) rand*0.06-0.03 randi([10 20]);
                          rand*0.06-0.03 1-(rand*0.1-0.05) randi([10 20]);
                          rand*0.0002+0.0002 rand*0.0002+0.0002 1];
            warpedImage = cv.warpPerspective(img, homoGround, ...
                'DSize',[200 200], 'Interpolation','Linear', 'WarpInverse',true);
            mapHomography = eye(3);
            mapHomography = cv.findTransformECC(warpedImage, img, ...
                'InputWarp',mapHomography, 'MotionType','Homography', ...
                'Criteria',struct('type','Count+EPS', 'maxCount',50, 'epsilon',-1));
            validateattributes(mapHomography, {'numeric'}, ...
                {'size',[3 3], 'nonnan', 'finite', '<',1e9});
            assert(norm(mapHomography - homoGround) < 0.1, 'Accuracy error');
        end

        function test_error_1
            try
                cv.findTransformECC();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

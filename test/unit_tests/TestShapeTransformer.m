classdef TestShapeTransformer
    %TestShapeTransformer

    methods (Static)
        function test_1
            img1 = cv.imread(fullfile(mexopencv.root(),'test','basketball1.png'), ...
                'Grayscale',true, 'ReduceScale',2);
            img2 = cv.imread(fullfile(mexopencv.root(),'test','basketball2.png'), ...
                'Grayscale',true, 'ReduceScale',2);

            detector = cv.AKAZE();
            [keypoints1, descriptors1] = detector.detectAndCompute(img1);
            [keypoints2, descriptors2] = detector.detectAndCompute(img2);
            matcher = cv.DescriptorMatcher('BFMatcher', ...
                'NormType',detector.defaultNorm());
            matches = matcher.match(descriptors1, descriptors2);
            pts1 = cat(1, keypoints1.pt);
            pts2 = cat(1, keypoints2.pt);

            for i=1:2
                if i==1
                    tps = cv.ShapeTransformer('AffineTransformer', ...
                        'FullAffine',true);
                    assert(isequal(tps.FullAffine, true));
                else
                    tps = cv.ShapeTransformer('ThinPlateSplineShapeTransformer', ...
                        'RegularizationParameter',25000);
                    assert(isequal(tps.RegularizationParameter, 25000));
                end

                tps.estimateTransformation(pts1, pts2, matches);

                [cost, pts3] = tps.applyTransformation(pts2);
                validateattributes(cost, {'numeric'}, {'scalar'});
                validateattributes(pts3, {'numeric'}, {'size',size(pts2)});

                img3 = tps.warpImage(img2);
                validateattributes(img3, {class(img2)}, {'size',size(img2)});
            end
        end
    end

end

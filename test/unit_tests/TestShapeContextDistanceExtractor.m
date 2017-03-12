classdef TestShapeContextDistanceExtractor
    %TestShapeContextDistanceExtractor

    methods (Static)
        function test_1
            img1 = cv.imread(fullfile(mexopencv.root(),'test','shape03.png'), ...
                'Grayscale',true, 'ReduceScale',2);
            img2 = cv.imread(fullfile(mexopencv.root(),'test','shape04.png'), ...
                'Grayscale',true, 'ReduceScale',2);
            c1 = cv.findContours(img1, 'Mode','List', 'Method','TC89_L1');
            c2 = cv.findContours(img2, 'Mode','List', 'Method','TC89_L1');
            [~,idx] = max(cellfun(@numel,c1));  % largest contour
            c1 = c1{idx};  % cell array of 2D points
            [~,idx] = max(cellfun(@numel,c2));  % largest contour
            c2 = c2{idx};  % cell array of 2D points

            sc = cv.ShapeContextDistanceExtractor('AngularBins',12, ...
                'CostExtractor',{'ChiHistogramCostExtractor', 'NDummies',25});
            sc.setTransformAlgorithm('ThinPlateSplineShapeTransformer');
            sc.RadialBins = 4;
            assert(isequal(sc.AngularBins, 12));
            assert(isstruct(sc.getCostExtractor()));

            sc.setImages(img1, img2);
            [im1,im2] = sc.getImages();
            validateattributes(im1, {class(img1)}, {'size',size(img1)});
            validateattributes(im2, {class(img2)}, {'size',size(img2)});
            assert(isequal(im1, img1));
            assert(isequal(im2, img2));

            d = sc.computeDistance(c1, c2);
            validateattributes(d, {'numeric'}, {'scalar', 'real'});
        end
    end

end

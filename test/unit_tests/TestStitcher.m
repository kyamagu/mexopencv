classdef TestStitcher
    %TestStitcher

    methods (Static)
        function test_1
            im1 = imread(fullfile(mexopencv.root(),'test','b1.jpg'));
            im2 = imread(fullfile(mexopencv.root(),'test','b2.jpg'));
            stitcher = cv.Stitcher();
            pano = stitcher.stitch({im1, im2});
            validateattributes(pano, {class(im1)}, {'ndims',ndims(im1)});
        end

        function test_2
            im1 = imread(fullfile(mexopencv.root(),'test','a1.jpg'));
            im2 = imread(fullfile(mexopencv.root(),'test','a2.jpg'));
            im3 = imread(fullfile(mexopencv.root(),'test','a3.jpg'));

            stitcher = cv.Stitcher();
            stitcher.RegistrationResol = 0.6;
            stitcher.SeamEstimationResol = 0.1;
            stitcher.CompositingResol = 'Orig';
            stitcher.PanoConfidenceThresh = 1;
            stitcher.WaveCorrection = true;
            stitcher.WaveCorrectKind = 'Horiz';
            stitcher.setFeaturesFinder('OrbFeaturesFinder', 'NLevels',5);
            stitcher.setFeaturesMatcher('BestOf2NearestMatcher', 'MatchConf',0.3);
            stitcher.setBundleAdjuster('BundleAdjusterRay', 'ConfThresh',1);
            stitcher.setWarper('SphericalWarper');
            stitcher.setExposureCompensator('BlocksGainCompensator');
            stitcher.setSeamFinder('GraphCutSeamFinder', 'CostType','ColorGrad');
            stitcher.setBlender('MultiBandBlender', 'NumBands',5);

            stitcher.estimateTransform({im1, im2, im3});
            pano = stitcher.composePanorama();
            validateattributes(pano, {class(im1)}, {'ndims',ndims(im1)});

            indices = stitcher.component();
            validateattributes(indices, {'numeric'}, {'vector', 'integer', 'nonnegative'});

            params = stitcher.cameras();
            validateattributes(params, {'struct'}, {});

            wscale = stitcher.workScale();
            validateattributes(wscale, {'numeric'}, {'scalar'});
        end
    end

end

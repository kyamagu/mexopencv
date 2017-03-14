classdef TestBundleAdjuster
    %TestBundleAdjuster

    properties (Constant)
        fields = {'aspect', 'focal', 'ppx', 'ppy', 'R', 't', 'K'};
    end

    methods (Static)
        function test_1
            img1 = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
            img2 = imread(fullfile(mexopencv.root(),'test','tsukuba_r.png'));

            finder = cv.FeaturesFinder('OrbFeaturesFinder');
            features = {finder.find(img1), finder.find(img2)};

            matcher = cv.FeaturesMatcher('BestOf2NearestMatcher');
            m = matcher.match_pairwise(features);

            estimator = cv.Estimator('HomographyBasedEstimator');
            cameras = estimator.estimate(features, m);
            for i=1:numel(cameras)
                cameras(i).R = single(cameras(i).R);
            end

            obj = cv.BundleAdjuster('BundleAdjusterRay');
            typename = obj.typeid();
            validateattributes(typename, {'char'}, {'row', 'nonempty'});

            [cameras2,success] = obj.refine(features, m, cameras);
            validateattributes(success, {'logical'}, {'scalar'});
            if success
                validateattributes(cameras2, {'struct'}, {'vector', 'numel',numel(cameras)});
                assert(all(ismember(TestBundleAdjuster.fields, fieldnames(cameras2))));
                for i=1:numel(cameras2)
                    validateattributes(cameras2(i).aspect, {'numeric'}, {'scalar'});
                    validateattributes(cameras2(i).focal, {'numeric'}, {'scalar'});
                    validateattributes(cameras2(i).ppx, {'numeric'}, {'scalar'});
                    validateattributes(cameras2(i).ppy, {'numeric'}, {'scalar'});
                    validateattributes(cameras2(i).R, {'numeric'}, {'size',[3 3]});
                    validateattributes(cameras2(i).t, {'numeric'}, {'vector','numel',3});
                    validateattributes(cameras2(i).K, {'numeric'}, {'size',[3 3]});
                end
            end
        end
    end

end

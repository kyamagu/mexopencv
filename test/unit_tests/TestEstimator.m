classdef TestEstimator
    %TestEstimator

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
            %matcher = cv.FeaturesMatcher('AffineBestOf2NearestMatcher');
            m = matcher.match_pairwise(features);

            obj = cv.Estimator('HomographyBasedEstimator');
            %obj = cv.Estimator('AffineBasedEstimator');
            typename = obj.typeid();
            validateattributes(typename, {'char'}, {'row', 'nonempty'});

            [cameras,success] = obj.estimate(features, m);
            validateattributes(success, {'logical'}, {'scalar'});
            if success
                validateattributes(cameras, {'struct'}, {'vector'});
                assert(all(ismember(TestEstimator.fields, fieldnames(cameras))));
                for i=1:numel(cameras)
                    validateattributes(cameras(i).aspect, {'numeric'}, {'scalar'});
                    validateattributes(cameras(i).focal, {'numeric'}, {'scalar'});
                    validateattributes(cameras(i).ppx, {'numeric'}, {'scalar'});
                    validateattributes(cameras(i).ppy, {'numeric'}, {'scalar'});
                    validateattributes(cameras(i).R, {'numeric'}, {'size',[3 3]});
                    validateattributes(cameras(i).t, {'numeric'}, {'vector','numel',3});
                    validateattributes(cameras(i).K, {'numeric'}, {'size',[3 3]});
                end
            end
        end
    end

end

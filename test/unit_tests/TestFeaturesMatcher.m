classdef TestFeaturesMatcher
    %TestFeaturesMatcher

    properties (Constant)
        fields = {'src_img_idx', 'dst_img_idx', 'matches', 'inliers_mask', ...
            'num_inliers', 'H', 'confidence'};
        dfields = {'queryIdx', 'trainIdx', 'imgIdx', 'distance'};
    end

    methods (Static)
        function test_1
            img1 = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
            img2 = imread(fullfile(mexopencv.root(),'test','tsukuba_r.png'));

            obj = cv.FeaturesFinder('OrbFeaturesFinder');
            feat1 = obj.find(img1);
            feat2 = obj.find(img2);

            matcher = cv.FeaturesMatcher('BestOf2NearestMatcher');
            typename = matcher.typeid();
            validateattributes(typename, {'char'}, {'row', 'nonempty'});

            ts = matcher.isThreadSafe();
            validateattributes(ts, {'logical'}, {'scalar'});

            m = matcher.match(feat1, feat2);
            validateattributes(m, {'struct'}, {'scalar'});
            assert(all(ismember(TestFeaturesMatcher.fields, fieldnames(m))));
            validateattributes(m.src_img_idx, {'numeric'}, {'scalar', 'integer'});
            validateattributes(m.dst_img_idx, {'numeric'}, {'scalar', 'integer'});
            validateattributes(m.matches, {'struct'}, {'vector'});
            assert(all(ismember(TestFeaturesMatcher.dfields, ...
                fieldnames(m.matches))));
            validateattributes(m.inliers_mask, {'numeric'}, ...
                {'vector', 'numel',numel(m.matches)});
            validateattributes(m.num_inliers, {'numeric'}, {'scalar'});
            validateattributes(m.H, {'numeric'}, {'size',[3 3]});
            validateattributes(m.confidence, {'numeric'}, {'scalar'});

            mm = matcher.match_pairwise({feat1, feat2});
            validateattributes(mm, {'struct'}, {'vector'});
            assert(all(ismember(TestFeaturesMatcher.fields, fieldnames(mm))));
        end
    end

end

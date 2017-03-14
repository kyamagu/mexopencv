classdef TestFeaturesFinder
    %TestFeaturesFinder

    properties (Constant)
        fields = {'img_idx', 'img_size', 'keypoints', 'descriptors'};
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
            ttypes = {'OrbFeaturesFinder'};  % 'AKAZEFeaturesFinder', 'SurfFeaturesFinder'
            for i=1:numel(ttypes)
                obj = cv.FeaturesFinder(ttypes{i});
                typename = obj.typeid();
                validateattributes(typename, {'char'}, {'row', 'nonempty'});

                feat = obj.find(img);
                validateattributes(feat, {'struct'}, {'scalar'});
                assert(all(ismember(TestFeaturesFinder.fields, fieldnames(feat))));
                validateattributes(feat.img_idx, {'numeric'}, {'scalar', 'integer'});
                validateattributes(feat.img_size, {'numeric'}, {'vector', 'numel',2});
                validateattributes(feat.keypoints, {'struct'}, {'vector'});
                assert(all(ismember(TestFeaturesFinder.kfields, ...
                    fieldnames(feat.keypoints))));
                validateattributes(feat.descriptors, {'numeric'}, ...
                    {'size',[numel(feat.keypoints) NaN]});
            end
        end
    end

end

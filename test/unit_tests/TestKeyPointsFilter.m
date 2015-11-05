classdef TestKeyPointsFilter
    %TestKeyPointsFilter
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','cat.jpg');
        fields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_filter
            img = imread(TestKeyPointsFilter.im);
            [h,w,~] = size(img);
            detector = cv.FeatureDetector('ORB');
            kpts = detector.detect(img);

            border = 50;
            kp = cv.KeyPointsFilter.runByImageBorder(kpts, [w,h], border);
            validateattributes(kp, {'struct'}, {'vector'});
            assert(all(ismember(TestKeyPointsFilter.fields, fieldnames(kp))));
            xy = cat(1, kp.pt);
            assert(all(xy(:,1) >= border & xy(:,1) <= w-border));
            assert(all(xy(:,2) >= border & xy(:,2) <= h-border));

            mn = 30; mx = 90;
            kp = cv.KeyPointsFilter.runByKeypointSize(kpts, mn, mx);
            validateattributes(kp, {'struct'}, {'vector'});
            assert(all(ismember(TestKeyPointsFilter.fields, fieldnames(kp))));
            assert(min([kp.size]) >= mn && max([kp.size]) <= mx);

            mask = zeros(h,w,'uint8');
            mask(1:fix(h/2),:) = 255;  % upper half of the image
            kp = cv.KeyPointsFilter.runByPixelsMask(kpts, mask);
            validateattributes(kp, {'struct'}, {'vector'});
            assert(all(ismember(TestKeyPointsFilter.fields, fieldnames(kp))));
            xy = cat(1, kp.pt);
            assert(all(xy(:,2) <= fix(h/2)));

            kp = cv.KeyPointsFilter.removeDuplicated(kpts);
            validateattributes(kp, {'struct'}, {'vector'});
            assert(all(ismember(TestKeyPointsFilter.fields, fieldnames(kp))));

            num = 50;
            kp = cv.KeyPointsFilter.retainBest(kpts, num);
            validateattributes(kp, {'struct'}, {'vector'});
            assert(all(ismember(TestKeyPointsFilter.fields, fieldnames(kp))));
            assert(numel(kp) <= num);
        end

        function test_convert_to
            kpts = cv.FAST(imread(TestKeyPointsFilter.im));

            pts = cv.KeyPointsFilter.convertToPoints(kpts);
            validateattributes(pts, {'cell'}, {'vector', 'numel',numel(kpts)});
            cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), pts);
            assert(isequal(pts, {kpts.pt}));

            pts = cv.KeyPointsFilter.convertToPoints(kpts, 'Indices',0:9);
            validateattributes(pts, {'cell'}, {'vector', 'numel',10});
            cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), pts);
            assert(isequal(pts, {kpts(1:10).pt}));
        end

        function test_convert_from
            pts = rand(10,2) * 10;

            kpts = cv.KeyPointsFilter.convertFromPoints(pts, ...
                'Size',10.0, 'Response',20.0, 'Octave',0, 'ClassId',-1);
            validateattributes(kpts, {'struct'}, ...
                {'vector', 'numel',size(pts,1)});
            assert(all(ismember(TestKeyPointsFilter.fields, ...
                fieldnames(kpts))));
            assert(norm(cat(1, kpts.pt) - pts) < 1e-5);
            assert(all([kpts.size] == 10.0));
            assert(all([kpts.response] == 20.0));
            assert(all([kpts.octave] == 0));
            assert(all([kpts.class_id] == -1));
        end

        function test_overlap
            kpts = cv.FAST(imread(TestKeyPointsFilter.im));
            ovrls = arrayfun(@(kp) ...
                cv.KeyPointsFilter.overlap(kpts(1), kp), kpts);
            validateattributes(ovrls, {'numeric'}, ...
                {'vector', 'real', 'numel',numel(kpts), '>=',0, '<=',1});
        end

        function test_hash
            kpts = cv.FAST(imread(TestKeyPointsFilter.im));
            hashes = arrayfun(@(k) cv.KeyPointsFilter.hash(k), kpts);
            validateattributes(hashes, {'uint64'}, ...
                {'vector', 'nonnegative', 'numel',numel(kpts)});
        end
    end

end

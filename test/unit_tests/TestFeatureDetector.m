classdef TestFeatureDetector
    %TestFeatureDetector
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
        detectors = { ...
            ... % features2d (opencv)
            'AgastFeatureDetector', 'FastFeatureDetector', ...
            'GFTTDetector', 'SimpleBlobDetector', 'MSER', ...
            'BRISK', 'ORB', 'KAZE', 'AKAZE', ...
            ... % xfeatures2d (opencv_contrib)
            'SIFT', 'SURF', 'StarDetector'
        };
    end

    methods (Static)
        function test_detect_img
            for i=1:numel(TestFeatureDetector.detectors)
                try
                    obj = cv.FeatureDetector(TestFeatureDetector.detectors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    fprintf('SKIPPED: %s\n', TestFeatureDetector.detectors{i});
                    continue;
                end
                typename = obj.typeid();

                kpts = obj.detect(TestFeatureDetector.img);
                validateattributes(kpts, {'struct'}, {'vector'});
                assert(all(ismember(TestFeatureDetector.kfields, ...
                    fieldnames(kpts))));
            end
        end

        function test_detect_imgset
            imgs = {TestFeatureDetector.img, TestFeatureDetector.img};
            for i=1:numel(TestFeatureDetector.detectors)
                try
                    obj = cv.FeatureDetector(TestFeatureDetector.detectors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    fprintf('SKIPPED: %s\n', TestFeatureDetector.detectors{i});
                    continue;
                end

                kpts = obj.detect(imgs);
                validateattributes(kpts, {'cell'}, ...
                    {'vector', 'numel',numel(imgs)});
                cellfun(@(kpt) validateattributes(kpt, ...
                    {'struct'}, {'vector'}), kpts);
                cellfun(@(kpt) assert(all(ismember(...
                    TestFeatureDetector.kfields, fieldnames(kpt)))), kpts);
            end
        end

        function test_detect_mask
            mask = zeros(size(TestFeatureDetector.img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image

            for i=1:numel(TestFeatureDetector.detectors)
                try
                    obj = cv.FeatureDetector(TestFeatureDetector.detectors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    fprintf('SKIPPED: %s\n', TestFeatureDetector.detectors{i});
                    continue;
                end

                kpts = obj.detect(TestFeatureDetector.img, 'Mask',mask);
                validateattributes(kpts, {'struct'}, {'vector'});
                assert(all(ismember(TestFeatureDetector.kfields, ...
                    fieldnames(kpts))));
                xy = cat(1, kpts.pt);
                assert(all(xy(:,1) <= ceil(size(TestFeatureDetector.img,2)/2)));
            end
        end
    end

end

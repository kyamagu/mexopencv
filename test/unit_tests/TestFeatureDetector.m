classdef TestFeatureDetector
    %TestFeatureDetector

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
        detectors = { ...
            ... % features2d (opencv)
            'AgastFeatureDetector', 'FastFeatureDetector', ...
            'GFTTDetector', 'SimpleBlobDetector', 'MSER', ...
            'BRISK', 'ORB', 'KAZE', 'AKAZE', ...
            ... % xfeatures2d (opencv_contrib)
            'SIFT', 'SURF', 'StarDetector', 'MSDDetector', ...
            'HarrisLaplaceFeatureDetector'
        };
    end

    methods (Static)
        function test_detect_img
            img = cv.imread(TestFeatureDetector.im, ...
                'Grayscale',true, 'ReduceScale',2);
            for i=1:numel(TestFeatureDetector.detectors)
                try
                    obj = cv.FeatureDetector(TestFeatureDetector.detectors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    %error('mexopencv:testskip', 'contrib');
                    continue;
                end
                typename = obj.typeid();

                kpts = obj.detect(img);
                validateattributes(kpts, {'struct'}, {'vector'});
                assert(all(ismember(TestFeatureDetector.kfields, ...
                    fieldnames(kpts))));
            end
        end

        function test_detect_imgset
            img = cv.imread(TestFeatureDetector.im, ...
                'Grayscale',true, 'ReduceScale',2);
            imgs = {img, img};
            for i=1:numel(TestFeatureDetector.detectors)
                try
                    obj = cv.FeatureDetector(TestFeatureDetector.detectors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    %error('mexopencv:testskip', 'contrib');
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
            img = imread(TestFeatureDetector.im);
            mask = zeros(size(img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image

            for i=1:numel(TestFeatureDetector.detectors)
                try
                    obj = cv.FeatureDetector(TestFeatureDetector.detectors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    %error('mexopencv:testskip', 'contrib');
                    continue;
                end

                kpts = obj.detect(img, 'Mask',mask);
                validateattributes(kpts, {'struct'}, {'vector'});
                assert(all(ismember(TestFeatureDetector.kfields, ...
                    fieldnames(kpts))));
                xy = cat(1, kpts.pt);
                assert(all(xy(:,1) <= ceil(size(img,2)/2)));
            end
        end
    end

end

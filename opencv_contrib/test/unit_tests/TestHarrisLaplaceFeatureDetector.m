classdef TestHarrisLaplaceFeatureDetector
    %TestHarrisLaplaceFeatureDetector

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_img
            obj = cv.HarrisLaplaceFeatureDetector('NumOctaves',6);
            typename = obj.typeid();

            img = imread(TestHarrisLaplaceFeatureDetector.im);
            kpts = obj.detect(img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestHarrisLaplaceFeatureDetector.kfields, fieldnames(kpts))));
        end

        function test_detect_imgset
            img = imread(TestHarrisLaplaceFeatureDetector.im);
            imgs = {img, img};
            obj = cv.HarrisLaplaceFeatureDetector();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(...
                ismember(TestHarrisLaplaceFeatureDetector.kfields, fieldnames(kpt)))), kpts);
        end

        function test_detect_mask
            img = imread(TestHarrisLaplaceFeatureDetector.im);
            mask = zeros(size(img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.HarrisLaplaceFeatureDetector();
            kpts = obj.detect(img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestHarrisLaplaceFeatureDetector.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(img,2)/2)));
        end

        function test_error_1
            try
                cv.HarrisLaplaceFeatureDetector('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestFastFeatureDetector
    %TestFastFeatureDetector
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_img
            img = imread(TestFastFeatureDetector.im);
            obj = cv.FastFeatureDetector('Threshold',10, 'NonmaxSuppression',true);
            assert(obj.Threshold == 10);
            assert(obj.NonmaxSuppression == true);
            typename = obj.typeid();

            kpts = obj.detect(img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestFastFeatureDetector.kfields, fieldnames(kpts))));
        end

        function test_detect_imgset
            img = imread(TestFastFeatureDetector.im);
            imgs = {img, img};
            obj = cv.FastFeatureDetector();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestFastFeatureDetector.kfields, fieldnames(kpt)))), kpts);
        end

        function test_detect_mask
            img = imread(TestFastFeatureDetector.im);
            mask = zeros(size(img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.FastFeatureDetector();
            kpts = obj.detect(img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestFastFeatureDetector.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(img,2)/2)));
        end

        function test_detect_types
            types = {'TYPE_5_8', 'TYPE_7_12', 'TYPE_9_16'};
            img = imread(TestFastFeatureDetector.im);
            obj = cv.FastFeatureDetector();
            for i=1:numel(types)
                obj.Type = types{i};
                kpts = obj.detect(img);
                validateattributes(kpts, {'struct'}, {'vector'});
            end
        end

        function test_error_1
            try
                cv.FastFeatureDetector('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

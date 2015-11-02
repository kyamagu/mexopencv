classdef TestAgastFeatureDetector
    %TestAgastFeatureDetector
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_img
            obj = cv.AgastFeatureDetector('Threshold',10, 'NonmaxSuppression',true);
            assert(obj.Threshold == 10);
            assert(obj.NonmaxSuppression == true);
            typename = obj.typeid();

            kpts = obj.detect(TestAgastFeatureDetector.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestAgastFeatureDetector.kfields, fieldnames(kpts))));
        end

        function test_detect_imgset
            imgs = {TestAgastFeatureDetector.img, TestAgastFeatureDetector.img};
            obj = cv.AgastFeatureDetector();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestAgastFeatureDetector.kfields, fieldnames(kpt)))), kpts);
        end

        function test_detect_mask
            mask = zeros(size(TestAgastFeatureDetector.img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.AgastFeatureDetector();
            kpts = obj.detect(TestAgastFeatureDetector.img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestAgastFeatureDetector.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(TestAgastFeatureDetector.img,2)/2)));
        end

        function test_detect_types
            types = {'AGAST_5_8', 'AGAST_7_12d', 'AGAST_7_12s', 'OAST_9_16'};
            obj = cv.AgastFeatureDetector();
            for i=1:numel(types)
                obj.Type = types{i};
                kpts = obj.detect(TestAgastFeatureDetector.img);
                validateattributes(kpts, {'struct'}, {'vector'});
            end
        end

        function test_error_1
            try
                cv.AgastFeatureDetector('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

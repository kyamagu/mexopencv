classdef TestStarDetector
    %TestStarDetector
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_img
            obj = cv.StarDetector('MaxSize',45, 'SuppressNonmaxSize',5);
            typename = obj.typeid();

            kpts = obj.detect(TestStarDetector.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestStarDetector.kfields, fieldnames(kpts))));
        end

        function test_detect_imgset
            imgs = {TestStarDetector.img, TestStarDetector.img};
            obj = cv.StarDetector();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestStarDetector.kfields, fieldnames(kpt)))), kpts);
        end

        function test_detect_mask
            mask = zeros(size(TestStarDetector.img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.StarDetector();
            kpts = obj.detect(TestStarDetector.img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestStarDetector.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(TestStarDetector.img,2)/2)));
        end

        function test_error_1
            try
                cv.StarDetector('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

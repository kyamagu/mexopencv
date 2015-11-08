classdef TestSimpleBlobDetector
    %TestSimpleBlobDetector
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_img
            obj = cv.SimpleBlobDetector('MinThreshold',50, 'MaxThreshold',220);
            typename = obj.typeid();

            img = imread(TestSimpleBlobDetector.im);
            kpts = obj.detect(img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestSimpleBlobDetector.kfields, fieldnames(kpts))));
        end

        function test_detect_imgset
            img = imread(TestSimpleBlobDetector.im);
            imgs = {img, img};
            obj = cv.SimpleBlobDetector();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestSimpleBlobDetector.kfields, fieldnames(kpt)))), kpts);
        end

        function test_detect_mask
            img = imread(TestSimpleBlobDetector.im);
            mask = zeros(size(img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.SimpleBlobDetector();
            kpts = obj.detect(img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestSimpleBlobDetector.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(img,2)/2)));
        end

        function test_error_1
            try
                cv.SimpleBlobDetector('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

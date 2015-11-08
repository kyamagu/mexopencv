classdef TestMSER
    %TestMSER
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_img
            obj = cv.MSER('MinArea',60);
            assert(obj.MinArea == 60);
            typename = obj.typeid();

            img = imread(TestMSER.im);
            kpts = obj.detect(img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestMSER.kfields, fieldnames(kpts))));
        end

        function test_detect_imgset
            img = imread(TestMSER.im);
            imgs = {img, img};
            obj = cv.MSER();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestMSER.kfields, fieldnames(kpt)))), kpts);
        end

        function test_detect_mask
            img = imread(TestMSER.im);
            mask = zeros(size(img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.MSER();
            kpts = obj.detect(img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestMSER.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(img,2)/2)));
        end

        function test_detectRegions
            img = imread(TestMSER.im);
            obj = cv.MSER();
            [chains, bboxes] = obj.detectRegions(img);
            if ~isempty(chains)
                validateattributes(chains, {'cell'}, ...
                    {'vector', 'numel',numel(bboxes)});
                cellfun(@(c) validateattributes(c, {'cell'}, {'vector'}), chains);
                cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                    {'numeric'}, {'vector', 'integer', 'numel',2}), c), chains);
            end
            if ~isempty(bboxes)
                validateattributes(bboxes, {'cell'}, ...
                    {'vector', 'numel',numel(chains)});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'integer', 'numel',4}), bboxes);
            end
        end

        function test_error_1
            try
                cv.MSER('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestSURF
    %TestSURF
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_compute_img
            obj = cv.SURF('Extended',false, 'Upright',false);
            assert(obj.Extended == false);
            assert(obj.Upright == false);
            typename = obj.typeid();
            ntype = obj.defaultNorm();

            kpts = obj.detect(TestSURF.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestSURF.kfields, fieldnames(kpts))));

            [desc, kpts2] = obj.compute(TestSURF.img, kpts);
            validateattributes(kpts2, {'struct'}, {'vector'});
            assert(all(ismember(TestSURF.kfields, fieldnames(kpts2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts2) obj.descriptorSize()]});
        end

        function test_detect_compute_imgset
            imgs = {TestSURF.img, TestSURF.img};
            obj = cv.SURF();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestSURF.kfields, fieldnames(kpt)))), kpts);

            [descs, kpts] = obj.compute(imgs, kpts);
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(d,k) validateattributes(d, {obj.descriptorType()}, ...
                {'size',[numel(k) obj.descriptorSize()]}), descs, kpts);
        end

        function test_detectAndCompute
            obj = cv.SURF();
            [kpts, desc] = obj.detectAndCompute(TestSURF.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestSURF.kfields, fieldnames(kpts))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detectAndCompute_providedKeypoints
            obj = cv.SURF();
            kpts = obj.detect(TestSURF.img);

            kpts = kpts(1:min(20,end));
            [~, desc] = obj.detectAndCompute(TestSURF.img, 'Keypoints',kpts);
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detect_mask
            mask = zeros(size(TestSURF.img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.SURF();
            kpts = obj.detect(TestSURF.img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestSURF.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(TestSURF.img,2)/2)));
        end

        function test_error_1
            try
                cv.SURF('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

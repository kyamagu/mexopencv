classdef TestORB
    %TestORB
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_compute_img
            obj = cv.ORB('MaxFeatures',500);
            assert(obj.MaxFeatures == 500);
            typename = obj.typeid();
            ntype = obj.defaultNorm();

            kpts = obj.detect(TestORB.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestORB.kfields, fieldnames(kpts))));

            [desc, kpts2] = obj.compute(TestORB.img, kpts);
            validateattributes(kpts2, {'struct'}, {'vector'});
            assert(all(ismember(TestORB.kfields, fieldnames(kpts2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts2) obj.descriptorSize()]});
        end

        function test_detect_compute_imgset
            imgs = {TestORB.img, TestORB.img};
            obj = cv.ORB();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestORB.kfields, fieldnames(kpt)))), kpts);

            [descs, kpts] = obj.compute(imgs, kpts);
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(d,k) validateattributes(d, {obj.descriptorType()}, ...
                {'size',[numel(k) obj.descriptorSize()]}), descs, kpts);
        end

        function test_detectAndCompute
            obj = cv.ORB();
            [kpts, desc] = obj.detectAndCompute(TestORB.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestORB.kfields, fieldnames(kpts))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detectAndCompute_providedKeypoints
            obj = cv.ORB();
            kpts = obj.detect(TestORB.img);

            kpts = kpts(1:min(20,end));
            [~, desc] = obj.detectAndCompute(TestORB.img, 'Keypoints',kpts);
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detect_mask
            mask = zeros(size(TestORB.img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.ORB();
            kpts = obj.detect(TestORB.img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestORB.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(TestORB.img,2)/2)));
        end

        function test_error_1
            try
                cv.ORB('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

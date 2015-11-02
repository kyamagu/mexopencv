classdef TestAKAZE
    %TestAKAZE
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id'};
    end

    methods (Static)
        function test_detect_compute_img
            obj = cv.AKAZE('DescriptorChannels',3);
            assert(obj.DescriptorChannels == 3);
            typename = obj.typeid();
            ntype = obj.defaultNorm();

            kpts = obj.detect(TestAKAZE.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestAKAZE.kfields, fieldnames(kpts))));

            [desc, kpts2] = obj.compute(TestAKAZE.img, kpts);
            validateattributes(kpts2, {'struct'}, {'vector'});
            assert(all(ismember(TestAKAZE.kfields, fieldnames(kpts2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts2) obj.descriptorSize()]});
        end

        function test_detect_compute_imgset
            imgs = {TestAKAZE.img, TestAKAZE.img};
            obj = cv.AKAZE();

            kpts = obj.detect(imgs);
            validateattributes(kpts, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(kpt) validateattributes(kpt, {'struct'}, {'vector'}), kpts);
            cellfun(@(kpt) assert(all(ismember(TestAKAZE.kfields, fieldnames(kpt)))), kpts);

            [descs, kpts] = obj.compute(imgs, kpts);
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(d,k) validateattributes(d, {obj.descriptorType()}, ...
                {'size',[numel(k) obj.descriptorSize()]}), descs, kpts);
        end

        function test_detectAndCompute
            obj = cv.AKAZE();
            [kpts, desc] = obj.detectAndCompute(TestAKAZE.img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestAKAZE.kfields, fieldnames(kpts))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detectAndCompute_providedKeypoints
            obj = cv.AKAZE();
            kpts = obj.detect(TestAKAZE.img);

            kpts = kpts(1:min(20,end));
            [~, desc] = obj.detectAndCompute(TestAKAZE.img, 'Keypoints',kpts);
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts) obj.descriptorSize()]});
        end

        function test_detect_mask
            mask = zeros(size(TestAKAZE.img), 'uint8');
            mask(:,1:end/2) = 255;  % only search left half of the image
            obj = cv.AKAZE();
            kpts = obj.detect(TestAKAZE.img, 'Mask',mask);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestAKAZE.kfields, fieldnames(kpts))));
            xy = cat(1, kpts.pt);
            assert(all(xy(:,1) <= ceil(size(TestAKAZE.img,2)/2)));
        end

        function test_desc_types
            types = {'KAZE', 'KAZEUpright', 'MLDB', 'MLDBUpright'};
            obj = cv.AKAZE();
            for i=1:numel(types)
                obj.DescriptorType = types{i};
                [kpts, desc] = obj.detectAndCompute(TestAKAZE.img);
                validateattributes(kpts, {'struct'}, {'vector'});
                validateattributes(desc, {obj.descriptorType()}, ...
                    {'size',[numel(kpts) obj.descriptorSize()]});
            end
        end

        function test_error_1
            try
                cv.AKAZE('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

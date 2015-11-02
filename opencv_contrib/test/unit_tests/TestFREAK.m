classdef TestFREAK
    %TestFREAK
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
    end

    methods (Static)
        function test_compute_img
            obj = cv.FREAK('OrientationNormalized',true, 'ScaleNormalized',true);
            typename = obj.typeid();
            ntype = obj.defaultNorm();

            kpts = cv.FAST(TestFREAK.img, 'Threshold',20);
            [desc, kpts2] = obj.compute(TestFREAK.img, kpts);
            validateattributes(kpts2, {'struct'}, {'vector'});
            assert(all(ismember(fieldnames(kpts), fieldnames(kpts2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts2) obj.descriptorSize()]});
        end

        function test_compute_imgset
            imgs = {TestFREAK.img, TestFREAK.img};
            kpts = cv.FAST(TestFREAK.img, 'Threshold',20);
            kpts = {kpts, kpts};

            obj = cv.FREAK();
            [descs, kpts] = obj.compute(imgs, kpts);
            validateattributes(kpts, {'cell'}, {'vector'});
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(d,k) validateattributes(d, {obj.descriptorType()}, ...
                {'size',[numel(k) obj.descriptorSize()]}), descs, kpts);
        end

        function test_error_1
            try
                cv.FREAK('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

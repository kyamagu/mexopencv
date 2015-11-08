classdef TestDAISY
    %TestDAISY
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
    end

    methods (Static)
        function test_compute_img
            obj = cv.DAISY('Radius',15, 'Normalization','None');
            typename = obj.typeid();
            ntype = obj.defaultNorm();

            img = imread(TestDAISY.im);
            kpts = cv.FAST(img, 'Threshold',20);
            [desc, kpts2] = obj.compute(img, kpts);
            validateattributes(kpts2, {'struct'}, {'vector'});
            assert(all(ismember(fieldnames(kpts), fieldnames(kpts2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts2) obj.descriptorSize()]});
        end

        function test_compute_imgset
            img = imread(TestDAISY.im);
            imgs = {img, img};
            kpts = cv.FAST(img, 'Threshold',20);
            kpts = {kpts, kpts};

            obj = cv.DAISY();
            [descs, kpts] = obj.compute(imgs, kpts);
            validateattributes(kpts, {'cell'}, {'vector'});
            validateattributes(descs, {'cell'}, {'vector', 'numel',numel(imgs)});
            cellfun(@(d,k) validateattributes(d, {obj.descriptorType()}, ...
                {'size',[numel(k) obj.descriptorSize()]}), descs, kpts);
        end

        function test_compute_all
            %TODO: crashes MATLAB
            if true
                disp('SKIP');
                return;
            end

            img = cv.resize(imread(TestDAISY.im), [64 64]);
            obj = cv.DAISY();

            desc = obj.compute_all(img);
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[NaN obj.descriptorSize()]});

            roi = round([0 0 size(img,2)/2 size(img,1)/2]);
            desc = obj.compute_all(img, roi);
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[NaN obj.descriptorSize()]});
        end

        function test_error_1
            try
                cv.DAISY('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

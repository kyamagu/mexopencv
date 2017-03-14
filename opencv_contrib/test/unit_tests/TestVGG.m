classdef TestVGG
    %TestVGG

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
    end

    methods (Static)
        function test_compute_img
            obj = cv.VGG('Desc','120', 'ScaleFactor',5.0);
            typename = obj.typeid();
            ntype = obj.defaultNorm();

            img = imread(TestVGG.im);
            kpts = cv.FAST(img, 'Threshold',20);
            [desc, kpts2] = obj.compute(img, kpts);
            validateattributes(kpts2, {'struct'}, {'vector'});
            assert(all(ismember(fieldnames(kpts), fieldnames(kpts2))));
            validateattributes(desc, {obj.descriptorType()}, ...
                {'size',[numel(kpts2) obj.descriptorSize()]});
        end

        function test_error_1
            try
                cv.VGG('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

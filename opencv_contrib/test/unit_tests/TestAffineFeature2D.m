classdef TestAffineFeature2D
    %TestAffineFeature2D

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        kfields = {'pt', 'size', 'angle', 'response', 'octave', 'class_id', ...
            'axes', 'si', 'transf'};
    end

    methods (Static)
        function test_detect_img
            %TODO:
            if true
                error('mexopencv:testskip', 'todo');
            end

            obj = cv.AffineFeature2D('SIFT');
            typename = obj.typeid();

            img = imread(TestAffineFeature2D.im);
            [kpts, descs] = obj.detectAndCompute_elliptic(img);
            validateattributes(kpts, {'struct'}, {'vector'});
            assert(all(ismember(TestAffineFeature2D.kfields, fieldnames(kpts))));
        end

        function test_error_1
            try
                cv.AffineFeature2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestFastHoughTransform
    %TestFastHoughTransform
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','building.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestFastHoughTransform.im, ...
                'Grayscale',true, 'ReduceScale',2);
            edges = cv.Canny(img, [50 200]);
            fht = cv.FastHoughTransform(edges, 'DDepth','int32', ...
                'AngleRange','ARO_315_135', 'Op','Addition');
            validateattributes(fht, {'int32'}, ...
                {'2d', 'nonempty', 'nonnegative'});
        end

        function test_error_1
            try
                cv.FastHoughTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

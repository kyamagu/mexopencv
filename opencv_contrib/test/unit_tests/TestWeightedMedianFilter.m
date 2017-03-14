classdef TestWeightedMedianFilter
    %TestWeightedMedianFilter

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            dst = cv.weightedMedianFilter(img, img, ...
                'Radius',5, 'WeightType','EXP');
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.weightedMedianFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestAdaptiveThreshold
    %TestAdaptiveThreshold
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','sudoku.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestAdaptiveThreshold.im, 'Grayscale',true);
            out = cv.adaptiveThreshold(img, 255);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = cv.imread(TestAdaptiveThreshold.im, 'Grayscale',true);
            out = cv.adaptiveThreshold(img, 255, 'AdaptiveMethod','Gaussian');
        end

        function test_3
            img = cv.imread(TestAdaptiveThreshold.im, 'Grayscale',true);
            out = cv.adaptiveThreshold(img, 255, 'ThresholdType','BinaryInv');
        end

        function test_4
            img = cv.imread(TestAdaptiveThreshold.im, 'Grayscale',true);
            out = cv.adaptiveThreshold(img, 255, 'BlockSize',7);
        end

        function test_5
            img = cv.imread(TestAdaptiveThreshold.im, 'Grayscale',true);
            out = cv.adaptiveThreshold(img, 255, 'C',1);
        end

        function test_error_1
            try
                cv.adaptiveThreshold();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestNiBlackThreshold
    %TestNiBlackThreshold

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','sudoku.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestNiBlackThreshold.im, 'Grayscale',true);
            out = cv.niBlackThreshold(img, -0.2);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = cv.imread(TestNiBlackThreshold.im, 'Grayscale',true);
            out = cv.niBlackThreshold(img, 0.2, ...
                'Type','Binary', 'BlockSize',7, 'MaxValue',255);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.niBlackThreshold();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

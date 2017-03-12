classdef TestAdaptiveThreshold
    %TestAdaptiveThreshold

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','sudoku.jpg');
    end

    methods (Static)
        function test_1
            img = cv.imread(TestAdaptiveThreshold.im, ...
                'Grayscale',true, 'ReduceScale',2);
            out = cv.adaptiveThreshold(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = cv.imread(TestAdaptiveThreshold.im, ...
                'Grayscale',true, 'ReduceScale',2);
            out = cv.adaptiveThreshold(img, 'Method','Gaussian', ...
                'Type','BinaryInv', 'BlockSize',7, 'C',1, 'MaxValue',255);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.adaptiveThreshold();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

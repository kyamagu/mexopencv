classdef TestL0Smooth
    %TestL0Smooth
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestL0Smooth.im);
            dst = cv.l0Smooth(img, 'Lambda',0.01);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.l0Smooth();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

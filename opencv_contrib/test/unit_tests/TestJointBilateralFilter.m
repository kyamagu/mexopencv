classdef TestJointBilateralFilter
    %TestJointBilateralFilter
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestJointBilateralFilter.im);
            dst = cv.jointBilateralFilter(img, img, 'Diameter',7);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.jointBilateralFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

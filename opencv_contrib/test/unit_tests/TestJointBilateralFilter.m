classdef TestJointBilateralFilter
    %TestJointBilateralFilter

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'Color',true, 'ReduceScale',2);
            dst = cv.jointBilateralFilter(img, img, 'Diameter',7);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.jointBilateralFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

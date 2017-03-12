classdef TestRollingGuidanceFilter
    %TestRollingGuidanceFilter

    methods (Static)
        function test_1
            img = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'Color',true, 'ReduceScale',2);
            dst = cv.rollingGuidanceFilter(img, 'SigmaSpace',3.0);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.rollingGuidanceFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

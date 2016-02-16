classdef TestRollingGuidanceFilter
    %TestRollingGuidanceFilter
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestRollingGuidanceFilter.im);
            dst = cv.rollingGuidanceFilter(img, 'SigmaSpace',3.0);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.rollingGuidanceFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestBilateralFilter
    %TestBilateralFilter
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_simple
            result = cv.bilateralFilter(TestBilateralFilter.img);
            validateattributes(result, {class(TestBilateralFilter.img)}, ...
                {'size',size(TestBilateralFilter.img)});
        end

        function test_options
            result = cv.bilateralFilter(TestBilateralFilter.img, ...
                'Diameter',7, 'SigmaColor',50, 'SigmaSpace',50, ...
                'BorderType','Default');
            validateattributes(result, {class(TestBilateralFilter.img)}, ...
                {'size',size(TestBilateralFilter.img)});
        end

        function test_error_argnum
            try
                cv.bilateralFilter();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_non_existant_option
            try
                cv.bilateralFilter(TestBilateralFilter.img,'foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_option_value
            try
                cv.bilateralFilter(TestBilateralFilter.img,'BorderType','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

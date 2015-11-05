classdef TestBilateralFilter
    %TestBilateralFilter
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_simple
            img = imread(TestBilateralFilter.im);
            result = cv.bilateralFilter(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_options
            img = imread(TestBilateralFilter.im);
            result = cv.bilateralFilter(img, ...
                'Diameter',7, 'SigmaColor',50, 'SigmaSpace',50, ...
                'BorderType','Default');
            validateattributes(result, {class(img)}, {'size',size(img)});
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
            img = imread(TestBilateralFilter.im);
            try
                cv.bilateralFilter(img, 'foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_option_value
            img = imread(TestBilateralFilter.im);
            try
                cv.bilateralFilter(img, 'BorderType','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

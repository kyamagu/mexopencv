classdef TestRectangle
    %TestRectangle

    methods (Static)
        function test_first_variant
            img = 255*ones(128,128,3,'uint8');
            out = cv.rectangle(img, [64,64], [20,10]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_second_variant
            img = 255*ones(128,128,3,'uint8');
            out = cv.rectangle(img, [64,64,20,10]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_compare_variants
            img = 255*ones([100,100,3],'uint8');
            x = 20; y = 30; w = 50; h = 40;
            out1 = cv.rectangle(img, [x,y,w,h]);
            out2 = cv.rectangle(img, [x,y], [x+w-1,y+h-1]);
            assert(isequal(out1,out2));
            validateattributes(out1, {class(img)}, {'size',size(img)});
            validateattributes(out2, {class(img)}, {'size',size(img)});
        end

        function test_options
            img = zeros(100,100,3,'double');
            out = cv.rectangle(img, [20,20], [80,80], ...
                'Color',[1 0 0], 'Thickness','Filled', 'LineType',8);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.rectangle();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_arg
            try
                cv.rectangle(zeros(100), [], []);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_nonexistant_option
            try
                cv.rectangle(zeros(100), [20,20,20,20], 'foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_invalid_option_value
            try
                cv.rectangle(zeros(100), [20,20], [20,20], 'LineType','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

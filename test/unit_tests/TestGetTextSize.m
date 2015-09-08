classdef TestGetTextSize
    %TestGetTextSize

    methods (Static)
        function test_simple
            sz = cv.getTextSize('foo');
            validateattributes(sz, {'numeric'}, {'vector', 'numel',2});
        end

        function test_options
            [sz,b] = cv.getTextSize('hello world', ...
                'FontFace','HersheyComplex', 'FontStyle','Italic', ...
                'FontScale',1.1, 'Thickness',2);
            validateattributes(sz, {'numeric'}, {'vector', 'numel',2});
            validateattributes(b, {'numeric'}, {'scalar'});
        end

        function test_error_1
            try
                cv.getTextSize();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

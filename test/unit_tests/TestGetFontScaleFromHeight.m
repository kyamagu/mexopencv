classdef TestGetFontScaleFromHeight
    %TestGetFontScaleFromHeight

    methods (Static)
        function test_simple
            x = cv.getFontScaleFromHeight(20);
            validateattributes(x, {'numeric'}, {'scalar', 'real'});
        end

        function test_options
            x = cv.getFontScaleFromHeight(20, ...
                'FontFace','HersheyComplex', 'FontStyle','Italic', 'Thickness',2);
            validateattributes(x, {'numeric'}, {'scalar', 'real'});
        end

        function test_error_argnum
            try
                cv.getFontScaleFromHeight();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

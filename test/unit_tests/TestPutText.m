classdef TestPutText
    %TestPutText

    methods (Static)
        function test_simple
            im = 255*ones(128,128,3,'uint8');
            out = cv.putText(im, 'foo', [5,30]);
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_options
            im = zeros([128,128,3],'uint8');
            out = cv.putText(im, 'foo', [40,70], ...
                'FontFace','HersheyComplex', 'FontStyle','Italic',...
                'Color',[255 0 0], 'Thickness',2, 'LineType','AA');
            validateattributes(out, {class(im)}, {'size',size(im)});
        end

        function test_error_1
            try
                cv.putText();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

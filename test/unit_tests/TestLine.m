classdef TestLine
    %TestLine

    methods (Static)
        function test_line
            img = 255*ones(64,64,3,'uint8');
            out = cv.line(img, [50,50], [20,10]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_options
            img = zeros([50,50,3],'uint8');
            out = cv.line(img, [10 10], [40 40], ...
                'Color',[255 0 0], 'Thickness',3, 'LineType','AA');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.line();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

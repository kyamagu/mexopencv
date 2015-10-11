classdef TestLine
    %TestLine

    methods (Static)
        function test_line
            img = 255*ones(128,128,3,'uint8');
            out = cv.line(img, [64,64], [20,10]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_options
            img = zeros([100,100,3],'uint8');
            out = cv.line(img, [20 20], [80 80], ...
                'Color',[255 0 0], 'Thickness',3, 'LineType','AA');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.line();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

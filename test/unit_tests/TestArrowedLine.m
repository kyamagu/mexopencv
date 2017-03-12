classdef TestArrowedLine
    %TestArrowedLine

    methods (Static)
        function test_1
            img = 255*ones(64,64,3,'uint8');
            out = cv.arrowedLine(img, [50,50], [20,10]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = zeros(64,64,3);
            out = cv.arrowedLine(img, [50,50], [20,10], 'Color',rand(1,3), ...
                'Thickness',2, 'LineType','AA', 'TipLength',0.2);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.arrowedLine();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

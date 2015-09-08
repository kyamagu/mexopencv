classdef TestArrowedLine
    %TestArrowedLine

    methods (Static)
        function test_1
            im = 255*ones(128,128,3,'uint8');
            a = cv.arrowedLine(im, [64,64], [20,10]);
            validateattributes(a, {class(im)}, {'size',size(im)});
        end

        function test_2
            im = zeros(128,128,3);
            a = cv.arrowedLine(im, [64,64], [20,10], 'Color',rand(1,3), ...
                'Thickness',2, 'LineType','AA', 'TipLength',0.2);
            validateattributes(a, {class(im)}, {'size',size(im)});
        end

        function test_error_1
            try
                cv.arrowedLine();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestLine
    %TestLine
    properties (Constant)
    end

    methods (Static)
        function test_line
            im = 255*ones(128,128,3,'uint8');
            im = cv.line(im, [64,64], [20,10]);
        end

        function test_options
            img = zeros([100,100,3],'uint8');
            img = cv.line(img, [20 20], [80 80], ...
                'Color',[255 0 0], 'Thickness',3, 'LineType','AA');
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

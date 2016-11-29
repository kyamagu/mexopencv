classdef TestDrawCharucoDiamond
    %TestDrawCharucoDiamond

    methods (Static)
        function test_1
            img = cv.drawCharucoDiamond('6x6_50', 0:3, 80, 50);
            validateattributes(img, {'uint8'}, {'size',[80 80]*3});
        end

        function test_2
            img = cv.drawCharucoDiamond('6x6_50', [10 20 30 40], 80, 50, ...
                'MarginSize',0, 'BorderBits',1);
            validateattributes(img, {'uint8'}, {'size',[80 80]*3});
        end

        function test_error_argnum
            try
                cv.drawCharucoDiamond();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

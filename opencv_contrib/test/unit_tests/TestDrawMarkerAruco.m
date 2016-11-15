classdef TestDrawMarkerAruco
    %TestDrawMarkerAruco

    methods (Static)
        function test_1
            img = cv.drawMarkerAruco('6x6_50', 0, 60);
            validateattributes(img, {'uint8'}, {'size',[60 60]});
        end

        function test_2
            img = cv.drawMarkerAruco('6x6_50', 0, 60, 'BorderBits',1);
            validateattributes(img, {'uint8'}, {'size',[60 60]});
        end

        function test_error_argnum
            try
                cv.drawMarkerAruco();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestCalcMotionGradient
    %TestCalcMotionGradient

    methods (Static)
        function test_error_1
            try
                cv.calcMotionGradient();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

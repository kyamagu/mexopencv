classdef TestCalcGlobalOrientation
    %TestCalcGlobalOrientation

    methods (Static)
        function test_error_1
            try
                cv.calcGlobalOrientation();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestComposeRT
    %TestComposeRT
    properties (Constant)
    end
    
    methods (Static)
        function test_error_1
            try
                cv.composeRT();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


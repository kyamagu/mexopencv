classdef TestFindHomography
    %TestFindHomography
    properties (Constant)
    end
    
    methods (Static)
        function test_error_1
            try
                cv.findHomography();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


classdef TestGetTextSize
    %TestGetTextSize
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            a = cv.getTextSize('foo');
        end
        
        function test_error_1
            try
                cv.getTextSize();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


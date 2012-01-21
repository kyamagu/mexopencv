classdef TestArcLength
    %TestArcLength
    properties (Constant)
        curve = {[0,0],[1,0],[2,2],[3,3],[3,4]};
    end
    
    methods (Static)
        function test_1
            len = cv.arcLength(TestArcLength.curve,'Closed',false);
        end
        
        function test_error_1
            try
                cv.arcLength();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


classdef TestContourArea
    %TestContourArea
    properties (Constant)
        curve = {[0,0],[1,0],[2,2],[3,3],[3,4]};
    end
    
    methods (Static)
        function test_1
            a = cv.contourArea(TestContourArea.curve);
        end
        
        function test_error_1
            try
                cv.contourArea();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


classdef TestMinAreaRect
    %TestMinAreaRect
    properties (Constant)
        p = {[0,0],[1,0],[2,2],[3,3],[3,4]};
    end
    
    methods (Static)
        function test_1
            rct = cv.minAreaRect(TestMinAreaRect.p);
        end
        
        function test_error_1
            try
                cv.minAreaRect();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


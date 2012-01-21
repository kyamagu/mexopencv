classdef TestApproxPolyDP
    %TestApproxPolyDP
    properties (Constant)
        curve = {[0,0],[1,1],[2,2],[3,3],[4,4]};
    end
    
    methods (Static)
        function test_1
            approxCurve = cv.approxPolyDP(TestApproxPolyDP.curve);
        end
        
        function test_error_1
            try
                cv.approxPolyDP();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


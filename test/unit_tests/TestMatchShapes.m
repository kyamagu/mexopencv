classdef TestMatchShapes
    %TestMatchShapes
    properties (Constant)
        contour1 = {[0,0],[1,0],[2,2],[3,3],[3,4]};
        contour2 = {[0,0],[1,0],[2,3],[3,3],[3,5]};
    end
    
    methods (Static)
        function test_1
            d = cv.matchShapes(TestMatchShapes.contour1,TestMatchShapes.contour2);
        end
        
        function test_error_1
            try
                cv.matchShapes();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


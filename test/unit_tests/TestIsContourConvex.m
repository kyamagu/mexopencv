classdef TestIsContourConvex
    %TestIsContourConvex
    properties (Constant)
        contour = {[0,0],[1,0],[2,2],[3,3],[3,4]};
    end
    
    methods (Static)
        function test_1
            b = cv.isContourConvex(TestIsContourConvex.contour);
        end
        
        function test_error_1
            try
                cv.isContourConvex();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


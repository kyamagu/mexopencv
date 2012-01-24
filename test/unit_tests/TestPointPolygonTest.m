classdef TestPointPolygonTest
    %TestPointPolygonTest
    properties (Constant)
        contour = {[0,0],[1,0],[2,2],[3,3],[3,4]};
    end
    
    methods (Static)
        function test_1
            b = cv.pointPolygonTest(TestPointPolygonTest.contour,[2.3,2.4]);
        end
        
        function test_error_1
            try
                cv.pointPolygonTest();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


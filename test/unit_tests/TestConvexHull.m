classdef TestConvexHull
    %TestConvexHull
    properties (Constant)
        points = {[0,0],[1,1],[2,2],[3,3],[4,4]};
        points2 = shiftdim([0,0;1,0;2,2;3,3;3,4],-1);
    end
    
    methods (Static)
        function test_1
            hull = cv.convexHull(TestConvexHull.points);
        end
        
        function test_2
            hull = cv.convexHull(TestConvexHull.points2);
        end
        
        function test_error_1
            try
                cv.convexHull();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


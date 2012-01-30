classdef TestConvertPointsFromHomogeneous
    %TestConvertPointsFromHomogeneous
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            pts = shiftdim([1,2,1;4,5,1],-1);
            rct = cv.convertPointsFromHomogeneous(pts);
        end
        
        function test_2
            pts = shiftdim([1,2,3,1;4,5,6,1],-1);
            rct = cv.convertPointsFromHomogeneous(pts);
        end
        
        function test_3
            pts = {[1,2,1],[4,5,1]};
            rct = cv.convertPointsFromHomogeneous(pts);
        end
        
        function test_4
            pts = {[1,2,3,1],[4,5,6,1]};
            rct = cv.convertPointsFromHomogeneous(pts);
        end
        
        function test_error_1
            try
                cv.convertPointsFromHomogeneous();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


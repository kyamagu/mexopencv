classdef TestConvertPointsToHomogeneous
    %TestConvertPointsToHomogeneous
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            pts = shiftdim([1,2;4,5],-1);
            rct = cv.convertPointsToHomogeneous(pts);
        end
        
        %function test_2
        %    pts = shiftdim([1,2,3;4,5,6],-1);
        %    rct = cv.convertPointsToHomogeneous(pts);
        %end
        
        function test_3
            pts = {[1,2],[4,5]};
            rct = cv.convertPointsToHomogeneous(pts);
        end
        
        %function test_4
        %    pts = {[1,2,3],[4,5,6]};
        %    rct = cv.convertPointsToHomogeneous(pts);
        %end
        
        function test_error_1
            try
                cv.convertPointsToHomogeneous();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


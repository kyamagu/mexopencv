classdef TestFillConvexPoly
    %TestFillConvexPoly
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = 255*ones(128,128,3,'uint8');
            pts = {[50,50],[50,70],[70,70]};
            a = cv.fillConvexPoly(im, pts, 'Color', [255,0,0]);
        end
        
        function test_error_1
            try
                cv.fillConvexPoly();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


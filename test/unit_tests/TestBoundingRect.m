classdef TestBoundingRect
    %TestBoundingRect
    properties (Constant)
        curve = {[0,0],[1,0],[2,2],[3,3],[3,4]};
    end
    
    methods (Static)
        function test_1
            rct = cv.boundingRect(TestBoundingRect.curve);
            assert(numel(rct)==4);
        end
        
        function test_error_1
            try
                cv.boundingRect();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


classdef TestGroupRectangles
    %TestGroupRectangles
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            rcts = {[0,1,10,10],...
                    [1,1,11,11],...
                    [10,10,20,20],...
                    [12,12,21,21],...
                    [30,40,10,20]};
            rslts = cv.groupRectangles(rcts,1);
        end
        
        function test_error_1
            try
                cv.groupRectangles();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


classdef TestRodrigues
    %TestRodrigues
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            M = [cos(pi/4),sin(pi/4),0;...
                -sin(pi/4),cos(pi/4),0;...
                         0,        0,1;];
            dst = cv.Rodrigues(M);
        end
        
        function test_error_1
            try
                cv.Rodrigues();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


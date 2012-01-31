classdef TestRQDecomp3x3
    %TestRQDecomp3x3
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            M = [cos(pi/4),sin(pi/4),0;...
                -sin(pi/4),cos(pi/4),0;...
                         0,        0,1;];
            dst = cv.RQDecomp3x3(M);
        end
        
        function test_error_1
            try
                cv.RQDecomp3x3();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


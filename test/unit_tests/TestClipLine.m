classdef TestClipLine
    %TestClipLine
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            [a,p1,p2] = cv.clipLine([64,64],[2,60],[60,2]);
            assert(a);
        end
        
        function test_2
            [a,p1,p2] = cv.clipLine([64,64],[65,80],[80,65]);
            assert(~a);
        end
        
        function test_3
            [a,p1,p2] = cv.clipLine([10,10,64,64],[65,80],[80,65]);
            assert(a);
        end
        
        function test_error_1
            try
                cv.clipLine();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


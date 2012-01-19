classdef TestIntegral
    %TestIntegral
    properties (Constant)
        img = [...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            ];
    end
    
    methods (Static)
        function test_1
            s = cv.integral(TestIntegral.img);
        end
        
        function test_2
            [s,sqsum] = cv.integral(TestIntegral.img);
        end
        
        function test_3
            [s,sqsum,tilted] = cv.integral(TestIntegral.img);
        end
        
        function test_error_1
            try
                cv.integral();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


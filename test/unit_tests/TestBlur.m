classdef TestBlur
    %TestBlur
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
            result = blur(TestBlur.img);
        end
        
        function test_2
            result = blur(TestBlur.img, 'KSize', [3,7]);
        end
        
        function test_3
            result = blur(TestBlur.img, 'Anchor', [0,1]);
        end
        
        function test_4
            result = blur(TestBlur.img, 'BorderType', 'Constant');
        end
        
        function test_error_1
            try
                blur();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


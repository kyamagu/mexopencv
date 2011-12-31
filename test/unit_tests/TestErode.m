classdef TestErode
    %TestErode
    properties (Constant)
        img = uint8([...
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
            ]);
    end
    
    methods (Static)
        function test_1
            result = erode(TestErode.img);
        end
        
        function test_3
            result = erode(TestErode.img, 'Anchor', [0,1]);
        end
        
        function test_4
            result = erode(TestErode.img, 'BorderType', 'Constant');
        end
        
        function test_error_1
            try
                erode();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


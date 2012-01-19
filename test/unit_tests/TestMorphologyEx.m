classdef TestMorphologyEx
    %TestMorphologyEx
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
            result = cv.morphologyEx(TestMorphologyEx.img, 'Tophat');
        end
        
        function test_3
            result = cv.morphologyEx(TestMorphologyEx.img, 'Tophat', 'Anchor', [0,1]);
        end
        
        function test_4
            result = cv.morphologyEx(TestMorphologyEx.img, 'Tophat', 'BorderType', 'Constant');
        end
        
        function test_error_1
            try
                cv.morphologyEx();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


classdef TestInpaint
    %TestInpaint
    properties (Constant)
        img = im2uint8(randn(10,10));
        mask = uint8([...
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
            result = cv.inpaint(TestInpaint.img,TestInpaint.mask);
        end
        
        function test_2
            result = cv.inpaint(TestInpaint.img,TestInpaint.mask,'Method','Telea');
        end
        
        function test_error_1
            try
                cv.inpaint();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


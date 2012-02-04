classdef TestCircle
    %TestCircle
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = 255*ones(128,128,3,'uint8');
            a = cv.circle(im, [64,64], 20);
        end
        
        function test_error_1
            try
                cv.circle();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


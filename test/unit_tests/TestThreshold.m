classdef TestThreshold
    %TestThreshold
    properties (Constant)
        img = im2uint8(randn(10,10));
    end
    
    methods (Static)
        function test_1
            result = cv.threshold(TestThreshold.img,0.5);
        end
        
        function test_error_1
            try
                cv.threshold();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


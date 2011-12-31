classdef TestAdaptiveThreshold
    %TestAdaptiveThreshold
    properties (Constant)
        img = uint8(randn(16,16)*255);
    end
    
    methods (Static)
        function test_1
            result = adaptiveThreshold(TestAdaptiveThreshold.img, 255);
        end
        
        function test_2
            result = adaptiveThreshold(TestAdaptiveThreshold.img, 255, 'AdaptiveMethod', 'Gaussian');
        end
        
        function test_3
            result = adaptiveThreshold(TestAdaptiveThreshold.img, 255, 'ThresholdType', 'BinaryInv');
        end
        
        function test_4
            result = adaptiveThreshold(TestAdaptiveThreshold.img, 255, 'BlockSize', 7);
        end
        
        function test_5
            result = adaptiveThreshold(TestAdaptiveThreshold.img, 255, 'C', 1);
        end
        
        function test_error_1
            try
                adaptiveThreshold();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


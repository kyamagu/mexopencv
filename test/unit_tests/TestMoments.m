classdef TestMoments
    %TestMoments
    properties (Constant)
        img = im2uint8(rand(10,10));
    end
    
    methods (Static)
        function test_1
            result = cv.moments(TestMoments.img);
        end
        
        function test_2
            result = cv.moments(TestMoments.img, 'BinaryImage', true);
        end
        
        function test_error_1
            try
                cv.moments();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


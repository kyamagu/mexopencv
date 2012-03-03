classdef TestInvert
    %TestKmeans
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            X = rand(4,4);
            [Y,d] = cv.invert(X);
        end
        
        function test_error_1
            try
                cv.invert();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


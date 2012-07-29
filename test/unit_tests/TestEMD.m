classdef TestEMD
    %TestEMD
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            H1 = single([1 0; 1 0;1 1;1  2;]);
            H2 = single([1 0;.5 0;1 1;.8 2;]);
            d = cv.EMD(H1, H2);
        end
        
        function test_error_1
            try
                cv.EMD();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


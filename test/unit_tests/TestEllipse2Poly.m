classdef TestEllipse2Poly
    %TestEllipse2Poly
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            a = cv.ellipse2Poly([64,64], [20,10]);
        end
        
        function test_error_1
            try
                cv.ellipse2Poly();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


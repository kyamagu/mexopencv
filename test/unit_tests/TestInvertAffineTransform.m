classdef TestInvertAffineTransform
    %TestInvertAffineTransform
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            src = [0, 1, 0; -1, 0, 1];
            ref = [0, -1, 1; 1, 0, 0];
            dst = cv.invertAffineTransform(src);
            assert(all(abs(dst(:)-ref(:))<1e-5));
        end
        
        function test_error_1
            try
                cv.invertAffineTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


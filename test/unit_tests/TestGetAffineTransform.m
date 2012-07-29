classdef TestGetAffineTransform
    %TestGetAffineTransform
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            ref = [0, 1, 0; -1, 0, 1];
            src = [0.0, 1.0; 1.0, 1.0; 1.0, 0.0];
            dst = [1.0, 1.0; 1.0, 0.0; 0.0, 0.0];
            t = cv.getAffineTransform(src,dst);
            assert(all(t(:) == ref(:)));
        end
        
        function test_error_1
            try
                cv.getAffineTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


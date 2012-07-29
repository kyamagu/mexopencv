classdef TestGetRectSubPix
    %TestGetRectSubPix
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            src = single([0,0,0;0,1,1;0,1,1]);
            ref = single([0,0;0,0.5625]);
            dst = cv.getRectSubPix(src,[2,2],[.25,.25]);
            assert(all(dst(:)==ref(:)));
        end
        
        function test_error_1
            try
                cv.getRectSubPix();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


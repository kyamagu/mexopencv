classdef TestRemap
    %TestRemap
    
    methods (Static)
        function test_1
            src = [1,0,0;0,0,0;0,0,0];
            X   = [0,0,0;0,0,0;0,0,0];
            Y   = [0,0,0;0,0,0;0,0,0];
            ref = [1,1,1;1,1,1;1,1,1];
            dst = cv.remap(src,X,Y);
            assert(all(ref(:)==dst(:)));
        end
        
        function test_2
            src = [1,0,0;0,0,0;0,0,0];
            X   = [0,0,0;0,0,0;0,0,0];
            Y   = [0,0,0;0,0,0;0,0,0];
            ref = [1,1,1;1,1,1;1,1,1];
            [m1,m2] = cv.convertMaps(X,Y);
            dst = cv.remap(src,m1,m2);
            assert(all(ref(:)==dst(:)));
        end
        
        function test_error_1
            try
                cv.remap();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


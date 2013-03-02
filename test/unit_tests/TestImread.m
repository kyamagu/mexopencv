classdef TestImread
    %TestImread
    properties (Constant)
        filename = fullfile(mexopencv.root(),'test','img001.jpg');
    end
    
    methods (Static)
        function test_1
            im = cv.imread(TestImread.filename);
        end
        
        function test_error_1
            try
                cv.imread();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        
        function test_error_2
            try
                cv.imread('foo.jpg');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


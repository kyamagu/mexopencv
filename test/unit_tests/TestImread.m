classdef TestImread
    %TestImread
    properties (Constant)
        path = fileparts(fileparts(mfilename('fullpath')))
        filename = [TestImread.path,filesep,'img001.jpg'];
    end
    
    methods (Static)
        function test_1
            im = imread(TestImread.filename);
        end
        
        function test_error_1
            try
                imread();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        
        function test_error_2
            try
                imread('foo.jpg');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


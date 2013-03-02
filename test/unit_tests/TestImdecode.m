classdef TestImdecode
    %TestImread
    properties (Constant)
        filename = fullfile(mexopencv.root(),'test','img001.jpg');
    end
    
    methods (Static)
        function test_1
            fid = fopen(TestImdecode.filename,'r');
            buf = fread(fid, inf, 'uint8=>uint8');
            fclose(fid);
            im = cv.imdecode(buf);
            assert(~isempty(im));
        end
        
        function test_error_1
            try
                cv.imdecode();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end

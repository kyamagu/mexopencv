classdef TestFileStorage
    %TestFileStorage
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            S = struct('field1', magic(4), 'field2', 'this is the second field');
            fname = [tempname '.yml'];
            cv.FileStorage(fname,S);
            S2 = cv.FileStorage(fname);
            assert(all(S.field1(:)==S2.field1(:)));
            assert(strcmp(S.field2,S2.field2));
            if exist(fname,'file')
                delete(fname);
            end
        end
        
        function test_error_1
            try
                cv.FileStorage();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


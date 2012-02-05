classdef TestFileStorage
    %TestFileStorage
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            S = struct('field1', magic(4), 'field2', 'this is the second field');
            cv.FileStorage('.my.yml',S);
            S2 = cv.FileStorage('.my.yml');
            assert(all(S.field1(:)==S2.field1(:)));
            assert(strcmp(S.field2,S2.field2));
            if exist('.my.yml','file')
				delete my.yml;
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


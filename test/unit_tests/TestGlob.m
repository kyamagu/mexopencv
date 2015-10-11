classdef TestGlob
    %TestGlob

    methods (Static)
        function test_1
            pattern = fullfile(mexopencv.root(),'test','left*.jpg');
            files = cv.glob(pattern, 'Recursive',false);
            validateattributes(files, {'cell'}, {'vector'});
            assert(iscellstr(files));
        end

        function test_error_1
            try
                cv.glob();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

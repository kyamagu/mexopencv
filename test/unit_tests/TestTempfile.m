classdef TestTempfile
    %TestTempfile

    methods (Static)
        function test_1
            fname = cv.tempfile();
            validateattributes(fname, {'char'}, {'vector'});
        end

        function test_2
            fname = cv.tempfile('Suffix','.txt');
            validateattributes(fname, {'char'}, {'vector'});
            assert(strncmp(fname(end-3:end), '.txt', 4));
        end

        function test_error_1
            try
                cv.tempfile('Foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

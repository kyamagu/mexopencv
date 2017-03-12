classdef TestCreateHanningWindow
    %TestCreateHanningWindow

    methods (Static)
        function test_1
            dst = cv.createHanningWindow([10 10], 'Type','single');
            validateattributes(dst, {'single'}, {'size',[10 10]});
        end

        function test_2
            dst = cv.createHanningWindow([10 20], 'Type','double');
            validateattributes(dst, {'double'}, {'size',[20 10]});
        end

        function test_error_argnum
            try
                cv.createHanningWindow();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

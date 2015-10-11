classdef TestCreateHanningWindow
    %TestCreateHanningWindow

    methods (Static)
        function test_1
            dst = cv.createHanningWindow([100 100], 'Type','single');
            validateattributes(dst, {'single'}, {'size',[100 100]});
        end

        function test_2
            dst = cv.createHanningWindow([10 20], 'Type','double');
            validateattributes(dst, {'double'}, {'size',[20 10]});
        end

        function test_error_1
            try
                cv.createHanningWindow();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

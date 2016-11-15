classdef TestGetBuildInformation
    %TestGetBuildInformation

    methods (Static)
        function test_1
            info = cv.getBuildInformation();
            assert(ischar(info) && ~isempty(info));
        end

        function test_error_1
            try
                cv.getBuildInformation('foobar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

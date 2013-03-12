classdef TestGetBuildInformation
    %TestGetBuildInformation

    properties (Constant)
    end

    methods (Static)
        function test_1
            info = cv.getBuildInformation();
            assert(ischar(info) && ~isempty(info));
        end

        function test_error
            try
                cv.getBuildInformation([]);
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

classdef TestUtils
    %TestUtils

    methods (Static)
        function test_1
            info = cv.Utils.getBuildInformation();
            assert(ischar(info) && ~isempty(info));
        end

        function test_2
            support = cv.Utils.checkHardwareSupport();
            assert(isstruct(support) && isscalar(support));
        end

        function test_3
            n = cv.Utils.getNumberOfCPUs();
            validateattributes(n, {'numeric'}, {'scalar', 'integer', 'nonnegative'});
        end

        function test_4
            n = cv.Utils.getNumThreads();
            validateattributes(n, {'numeric'}, {'scalar', 'integer'});
            cv.Utils.setNumThreads(n);
        end

        function test_5
            tf = cv.Utils.useOptimized();
            validateattributes(tf, {'logical'}, {'scalar'});
            cv.Utils.setUseOptimized(tf);
        end
    end

end

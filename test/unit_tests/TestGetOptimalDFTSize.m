classdef TestGetOptimalDFTSize
    %TestGetOptimalDFTSize

    methods (Static)
        function test_1
            N = cv.getOptimalDFTSize(101);
            validateattributes(N, {'numeric'}, {'scalar', 'integer'});
        end

        function test_error_argnum
            try
                cv.getOptimalDFTSize();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

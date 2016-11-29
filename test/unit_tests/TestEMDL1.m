classdef TestEMDL1
    %TestEMDL1

    methods (Static)
        function test_1
            sig1 = randn(20,1);
            sig2 = randn(20,1);
            d = cv.EMDL1(sig1, sig2);
            validateattributes(d, {'numeric'}, {'scalar', 'real'});
        end

        function test_2
            sig1 = randn(20,1);
            d = cv.EMDL1(sig1, sig1);
            validateattributes(d, {'numeric'}, {'scalar', 'real'});
        end

        function test_error_argnum
            try
                cv.EMDL1();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

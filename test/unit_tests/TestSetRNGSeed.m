classdef TestSetRNGSeed
    %TestSetRNGSeed

    methods (Static)
        function test_1
            % seed=0 equivalent to default seed of 0xffffffff
            cv.setRNGSeed(0);
        end

        function test_error_argnum
            try
                cv.setRNGSeed();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

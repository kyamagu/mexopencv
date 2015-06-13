classdef TestDemosaicing
    %TestDemosaicing
    properties (Constant)
    end

    methods (Static)
        function test_1
            src = randi([0 255], [200 200 1], 'uint8');
            dst = cv.demosaicing(src, 'BayerBG2RGB');
        end

        function test_error_1
            try
                cv.demosaicing();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

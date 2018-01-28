classdef TestFisheyeStereoCalibrate
    %TestFisheyeStereoCalibrate

    methods (Static)
        function test_1
            %TODO
        end

        function test_error_argnum
            try
                cv.fisheyeStereoCalibrate();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

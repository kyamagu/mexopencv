classdef TestCvtColorTwoPlane
    %TestCvtColorTwoPlane

    methods (Static)
        function test_1
            Y = randi([16 240], [48 64], 'uint8');
            UV = randi([0 255], [24 32 2], 'uint8');
            RGB = cv.cvtColorTwoPlane(Y, UV, 'YUV2RGB_NV12');
            validateattributes(RGB, {'uint8'}, {'size', [48 64 3]});
        end

        function test_error_argnum
            try
                cv.cvtColorTwoPlane();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

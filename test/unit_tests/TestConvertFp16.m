classdef TestConvertFp16
    %TestConvertFp16

    methods (Static)
        function test_1
            % fp32 -> fp16
            fp32 = rand([5 6], 'single');
            fp16 = cv.convertFp16(fp32);
            validateattributes(fp16, {'int16'}, {'size',size(fp32)});

            % fp16 -> fp32
            fp = cv.convertFp16(fp16);
            validateattributes(fp, {'single'}, {'size',size(fp32)});
            assert(norm(fp32 - fp) < 1e-3, 'bad accuracy');
        end

        function test_error_argnum
            try
                cv.convertFp16();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

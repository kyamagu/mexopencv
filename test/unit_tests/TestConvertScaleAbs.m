classdef TestConvertScaleAbs
    %TestConvertScaleAbs

    methods (Static)
        function test_1
            A = rand([10 10], 'single')*200 - 100;
            B = cv.convertScaleAbs(A, 'Alpha',5, 'Beta',3);
            validateattributes(B, {'uint8'}, {'size',size(A)});
        end

        function test_error_argnum
            try
                cv.convertScaleAbs();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

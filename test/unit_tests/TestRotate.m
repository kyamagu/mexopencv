classdef TestRotate
    %TestRotate

    methods (Static)
        function test_1
            src = magic(5);

            codes = {'90CW', '90CCW', '180'};
            for i=1:numel(codes)
                dst = cv.rotate(src, codes{i});
                validateattributes(dst, {class(src)}, {'size',size(src)});
            end
        end

        function test_error_argnum
            try
                cv.rotate();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

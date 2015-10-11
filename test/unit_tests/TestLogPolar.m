classdef TestLogPolar
    %TestLogPolar

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            dst = cv.logPolar(img, [100 100], 50);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.logPolar();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

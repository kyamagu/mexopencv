classdef TestLinearPolar
    %TestLinearPolar

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            dst = cv.linearPolar(img, [100 100], 500);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.linearPolar();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

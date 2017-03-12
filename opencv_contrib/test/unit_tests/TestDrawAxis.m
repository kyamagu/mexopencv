classdef TestDrawAxis
    %TestDrawAxis

    methods (Static)
        function test_1
            img = zeros([50 50 3], 'uint8');
            camMat = eye(3);
            distCoef = zeros(1,5);
            rvec = zeros(1,3);
            tvec = zeros(1,3);
            len = 1;
            out = cv.drawAxis(img, camMat, distCoef, rvec, tvec, len);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.drawAxis();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

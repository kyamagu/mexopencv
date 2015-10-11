classdef TestInitWideAngleProjMap
    %TestInitWideAngleProjMap

    methods (Static)
        function test_1
            camMat = eye(3);
            distCoeffs = zeros(1,4);
            sz = [50 100];  % [w,h]
            dw = 80;        % w
            [map1,map2,scale] = cv.initWideAngleProjMap(...
                camMat, distCoeffs, sz, dw, 'M1Type','int16');
            validateattributes(map1, {'int16'}, {'ncols',dw, 'ndims',3});
            validateattributes(map2, {'uint16'}, {'ncols',dw, 'ndims',2});
            validateattributes(scale, {'numeric'}, {'scalar'});
        end

        function test_error_1
            try
                cv.initWideAngleProjMap();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

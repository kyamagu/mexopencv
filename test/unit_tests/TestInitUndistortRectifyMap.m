classdef TestInitUndistortRectifyMap
    %TestInitUndistortRectifyMap

    methods (Static)
        function test_1
            camMat = eye(3);
            distCoeffs = zeros(1,4);
            newCamMat = cv.getDefaultNewCameraMatrix(camMat);
            sz = [50 100];  % [w,h]
            [map1,map2] = cv.initUndistortRectifyMap(...
                camMat, distCoeffs, newCamMat, sz, 'M1Type','int16');
            validateattributes(map1, {'int16'}, {'size',[sz(2) sz(1) 2]});
            validateattributes(map2, {'uint16'}, {'size',[sz(2) sz(1)]});
        end

        function test_2
            camMat = eye(3);
            distCoeffs = zeros(1,4);
            newCamMat = cv.getDefaultNewCameraMatrix(camMat);
            sz = [50 100];  % [w,h]
            [map1,map2] = cv.initUndistortRectifyMap(...
                camMat, distCoeffs, newCamMat, sz, 'M1Type','single1');
            validateattributes(map1, {'single'}, {'size',[sz(2) sz(1)]});
            validateattributes(map2, {'single'}, {'size',[sz(2) sz(1)]});
        end

        function test_3
            camMat = eye(3);
            distCoeffs = zeros(1,4);
            newCamMat = cv.getDefaultNewCameraMatrix(camMat);
            sz = [50 100];  % [w,h]
            [map1,map2] = cv.initUndistortRectifyMap(...
                camMat, distCoeffs, newCamMat, sz, 'M1Type','single2');
            validateattributes(map1, {'single'}, {'size',[sz(2) sz(1) 2]});
            assert(isempty(map2));
        end

        function test_error_1
            try
                cv.initUndistortRectifyMap();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestSolvePnP
    %TestSolvePnP
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            objPoints = rand(10,3);
            imgPoints = rand(10,2);
            camMatrix = eye(3);
            distCoeffs = zeros(5,1);
            [rvec,tvec] = cv.solvePnP(objPoints, imgPoints, camMatrix, distCoeffs);
        end

        function test_error_1
            try
                cv.solvePnP();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
    
end


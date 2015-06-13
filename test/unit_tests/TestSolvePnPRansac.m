classdef TestSolvePnPRansac
    %TestSolvePnP
    properties (Constant)
    end

    methods (Static)
        function test_1
            objPoints = rand(10,3);
            imgPoints = rand(10,2);
            camMatrix = eye(3);
            distCoeffs = zeros(5,1);
            [rvec,tvec,inliers,b] = cv.solvePnPRansac(objPoints, imgPoints, ...
                camMatrix, 'DistCoeffs',distCoeffs, 'Method','Iterative');
            assert(isvector(rvec) && numel(rvec) == 3);
            assert(isvector(tvec) && numel(tvec) == 3);
            assert(isvector(inliers) || isempty(inliers));
            assert(islogical(b) && isscalar(b));
        end

        function test_2
            objPoints = rand(10,1,3);
            imgPoints = rand(10,1,2);
            camMatrix = eye(3);
            [rvec,tvec,inliers] = cv.solvePnPRansac(objPoints, imgPoints, camMatrix);
        end

        function test_3
            objPoints = rand(1,10,3);
            imgPoints = rand(1,10,2);
            camMatrix = eye(3);
            [rvec,tvec,inliers] = cv.solvePnPRansac(objPoints, imgPoints, camMatrix);
        end

        function test_4
            objPoints = num2cell(rand(10,3),2);
            imgPoints = num2cell(rand(10,2),2);
            camMatrix = eye(3);
            [rvec,tvec,inliers] = cv.solvePnPRansac(objPoints, imgPoints, camMatrix);
        end

        function test_5
            objPoints = num2cell(rand(10,3),2);
            imgPoints = num2cell(rand(10,2),2);
            camMatrix = eye(3);
            rvec = rand(3,1);
            tvec = rand(3,1);
            [rvec,tvec,inliers] = cv.solvePnPRansac(objPoints, imgPoints, camMatrix, ...
                'Rvec',rvec, 'Tvec',tvec, 'UseExtrinsicGuess',true);
        end

        function test_error_1
            try
                cv.solvePnPRansac();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end


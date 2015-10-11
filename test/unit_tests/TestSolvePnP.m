classdef TestSolvePnP
    %TestSolvePnP

    methods (Static)
        function test_numeric_Nxd
            N = 10;
            objPoints = rand(N,3);
            imgPoints = rand(N,2);
            camMatrix = eye(3);
            distCoeffs = zeros(1,5);
            methodsPNP = {'Iterative', 'EPnP', 'P3P', 'DLS', 'UPnP'};
            for i=1:numel(methodsPNP)
                if strcmp(methodsPNP{i}, 'P3P')
                    n = 4;  % requires exactly 4 points
                else
                    n = N;
                end
                [rvec,tvec,success] = cv.solvePnP(...
                    objPoints(1:n,:), imgPoints(1:n,:), camMatrix, ...
                    'DistCoeffs',distCoeffs, 'Method',methodsPNP{i});
                validateattributes(rvec, {'double'}, {'vector', 'numel',3});
                validateattributes(tvec, {'double'}, {'vector', 'numel',3});
                validateattributes(success, {'logical'}, {'scalar'});
            end
        end

        function test_numeric_Nx1xd
            objPoints = rand(10,1,3);
            imgPoints = rand(10,1,2);
            camMatrix = eye(3);
            [rvec,tvec,success] = cv.solvePnP(objPoints, imgPoints, camMatrix);
            validateattributes(rvec, {'double'}, {'vector', 'numel',3});
            validateattributes(tvec, {'double'}, {'vector', 'numel',3});
            validateattributes(success, {'logical'}, {'scalar'});
        end

        function test_numeric_1xNxd
            objPoints = rand(1,10,3);
            imgPoints = rand(1,10,2);
            camMatrix = eye(3);
            [rvec,tvec,success] = cv.solvePnP(objPoints, imgPoints, camMatrix);
            validateattributes(rvec, {'double'}, {'vector', 'numel',3});
            validateattributes(tvec, {'double'}, {'vector', 'numel',3});
            validateattributes(success, {'logical'}, {'scalar'});
        end

        function test_cellarray
            objPoints = num2cell(rand(10,3),2);
            imgPoints = num2cell(rand(10,2),2);
            camMatrix = eye(3);
            [rvec,tvec,success] = cv.solvePnP(objPoints, imgPoints, camMatrix);
            validateattributes(rvec, {'double'}, {'vector', 'numel',3});
            validateattributes(tvec, {'double'}, {'vector', 'numel',3});
            validateattributes(success, {'logical'}, {'scalar'});
        end

        function test_initial_guess
            objPoints = num2cell(rand(10,3),2);
            imgPoints = num2cell(rand(10,2),2);
            camMatrix = eye(3);
            rvec = rand(3,1);
            tvec = rand(3,1);
            [rvec,tvec,success] = cv.solvePnP(objPoints, imgPoints, camMatrix, ...
                'Rvec',rvec, 'Tvec',tvec, ...
                'UseExtrinsicGuess',true, 'Method','Iterative');
            validateattributes(rvec, {'double'}, {'vector', 'numel',3});
            validateattributes(tvec, {'double'}, {'vector', 'numel',3});
            validateattributes(success, {'logical'}, {'scalar'});
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

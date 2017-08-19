classdef TestSolveP3P
    %TestSolveP3P

    methods (Static)
        function test_numeric_Nxd
            N = 3;  % must be exactly 3 points
            objPoints = rand(N,3);
            imgPoints = rand(N,2);
            camMatrix = eye(3);
            distCoeffs = zeros(1,5);
            methodsP3P = {'P3P', 'AP3P'};
            for i=1:numel(methodsP3P)
                [rvecs,tvecs,num] = cv.solveP3P(...
                    objPoints, imgPoints, camMatrix, ...
                    'DistCoeffs',distCoeffs, 'Method',methodsP3P{i});
                validateattributes(rvecs, {'cell'}, {'vector'});
                cellfun(@(v) validateattributes(v, {'numeric'}, ...
                    {'vector', 'numel',3}), rvecs);
                validateattributes(tvecs, {'cell'}, {'vector'});
                cellfun(@(v) validateattributes(v, {'numeric'}, ...
                    {'vector', 'numel',3}), tvecs);
                validateattributes(num, {'numeric'}, {'scalar', 'integer'});
                assert(isequal(num, numel(rvecs), numel(tvecs)));
            end
        end

        function test_numeric_Nx1xd
            N = 3;
            objPoints = rand(N,1,3);
            imgPoints = rand(N,1,2);
            camMatrix = eye(3);
            [rvecs,tvecs,num] = cv.solveP3P(objPoints, imgPoints, camMatrix);
            validateattributes(rvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), rvecs);
            validateattributes(tvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), tvecs);
            validateattributes(num, {'numeric'}, {'scalar', 'integer'});
            assert(isequal(num, numel(rvecs), numel(tvecs)));
        end

        function test_numeric_1xNxd
            N = 3;
            objPoints = rand(1,N,3);
            imgPoints = rand(1,N,2);
            camMatrix = eye(3);
            [rvecs,tvecs,num] = cv.solveP3P(objPoints, imgPoints, camMatrix);
            validateattributes(rvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), rvecs);
            validateattributes(tvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), tvecs);
            validateattributes(num, {'numeric'}, {'scalar', 'integer'});
            assert(isequal(num, numel(rvecs), numel(tvecs)));
        end

        function test_cellarray
            N = 3;
            objPoints = num2cell(rand(N,3),2);
            imgPoints = num2cell(rand(N,2),2);
            camMatrix = eye(3);
            [rvecs,tvecs,num] = cv.solveP3P(objPoints, imgPoints, camMatrix);
            validateattributes(rvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), rvecs);
            validateattributes(tvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), tvecs);
            validateattributes(num, {'numeric'}, {'scalar', 'integer'});
            assert(isequal(num, numel(rvecs), numel(tvecs)));
        end

        function test_error_argnum
            try
                cv.solveP3P();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

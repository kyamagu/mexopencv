classdef TestRecoverPose
    %TestRecoverPose

    methods (Static)
        function test_1
            N = 10;
            p1 = rand(N,2);
            p2 = rand(N,2);
            K = eye(3);
            [E, mask] = cv.findEssentialMat(p1, p2, ...
                'CameraMatrix',K, 'Method','Ransac');
            [R, t, good, mask2] = cv.recoverPose(E, p1, p2, ...
                'CameraMatrix',K, 'Mask',mask);
            validateattributes(R, {'numeric'}, {'size',[3 3]});
            validateattributes(t, {'numeric'}, {'vector', 'numel',3});
            validateattributes(good, {'numeric'}, {'scalar', 'integer'});
            validateattributes(mask2, {'numeric','logical'}, ...
                {'vector', 'numel',N, 'binary'});
        end

        function test_2
            % we load data from CVST toolbox
            if mexopencv.isOctave() || ~mexopencv.require('vision')
                error('mexopencv:testskip', 'toolbox');
            end

            load stereoPointPairs
            [E,mask] = cv.findEssentialMat(matchedPoints1, matchedPoints2);
            [R, t, ~, mask] = cv.recoverPose(...
                E, matchedPoints1, matchedPoints2, 'Mask',mask);
            validateattributes(R, {'numeric'}, {'size',[3 3]});
            validateattributes(t, {'numeric'}, {'vector', 'numel',3});
            validateattributes(mask, {'numeric','logical'}, ...
                {'vector', 'numel',size(matchedPoints1,1), 'binary'});
        end

        function test_error_argnum
            try
                cv.recoverPose();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

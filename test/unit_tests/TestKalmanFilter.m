classdef TestKalmanFilter
    %TestKalmanFilter
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            kf = cv.KalmanFilter(5,4,'ControlParams',2);
            % Set
            kf.statePre = ones(5,1);
            kf.statePost = ones(5,1);
            kf.transitionMatrix = ones(5,5);
            kf.controlMatrix = ones(5,2);
            kf.measurementMatrix = ones(4,5);
            kf.processNoiseCov = ones(5,5);
            kf.measurementNoiseCov = ones(4,4);
            kf.errorCovPre = ones(5,5);
            kf.gain = ones(5,4);
            kf.errorCovPost = ones(5,5);
            % Get
            kf.statePre;
            kf.statePost;
            kf.transitionMatrix;
            kf.controlMatrix;
            kf.measurementMatrix;
            kf.processNoiseCov;
            kf.measurementNoiseCov;
            kf.errorCovPre;
            kf.gain;
            kf.errorCovPost;
        end
    end
    
end


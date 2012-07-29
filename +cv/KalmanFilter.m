classdef KalmanFilter < handle
    %KALMANFILTER  Kalman filter class
    %
    % The class implements a standard Kalman filter
    % http://en.wikipedia.org/wiki/Kalman_filter, [Welch95]. However, you can
    % modify transitionMatrix, controlMatrix, and measurementMatrix to get an
    % extended Kalman filter functionality.
    %
    %    % initialization
    %    kf = cv.KalmanFilter(4,2);
    %    kf.statePre = [10;20;0;0]; % initial state prediction
    %    kf.transitionMatrix = [1,0,1,0; 0,1,0,1; 0,0,1,0; 0,0,0,1];
    %    kf.measurementMatrix([1,4]) = 1;
    %    kf.processNoiseCov = eye(4) * 1e-4;
    %    kf.measurementNoiseCov = eye(2) * 1e-1;
    %    kf.errorCovPost = eye(4) * 0.1;
    %    
    %    % dynamics
    %    p_pred = kf.predict;         % update internal state
    %    measure = [11;21];           % measurement
    %    p_est = kf.correct(measure); % correct
    %
    % See also cv.KalmanFilter.KalmanFilter cv.KalmanFilter.predict
    % cv.KalmanFilter.correct
    %
    
    properties (SetAccess = private)
        id % Object id
    end
    
    properties (Dependent)
        statePre            % predicted state `(x'(k)): x(k)=A*x(k-1)+B*u(k)`
        statePost           % corrected state `(x(k)): x(k)=x'(k)+K(k)*(z(k)-H*x'(k))`
        transitionMatrix    % state transition matrix `(A)`
        controlMatrix       % control matrix `(B)` (not used if there is no control)
        measurementMatrix   % measurement matrix `(H)`
        processNoiseCov     % process noise covariance matrix `(Q)`
        measurementNoiseCov % measurement noise covariance matrix `(R)`
        errorCovPre         % priori error estimate covariance matrix `(P'(k)): P'(k)=A*P(k-1)*At + Q`
        gain                % Kalman gain matrix `(K(k)): K(k)=P'(k)*Ht*inv(H*P'(k)*Ht+R`)
        errorCovPost        % posteriori error estimate covariance matrix `(P(k)): P(k)=(I-K(k)*H)*P'(k)`
    end
    
    methods
        function this = KalmanFilter(varargin)
            %KALMANFILTER  KalmanFilter constructor
            %
            %    kf = cv.KalmanFilter
            %    kf = cv.KalmanFilter(dynamParams, measureParams)
            %    kf = cv.KalmanFilter(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __dynamParams__ Dimensionality of the state.
            % * __measureParams__ Dimensionality of the measurement.
            %
            % ## Options
            % * __ControlParams__ Dimensionality of the control vector.
            %
            %
            % See also cv.KalmanFilter cv.KalmanFilter.init
            %
            this.id = KalmanFilter_();
            if nargin>0, this.init(varargin{:}); end
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.KalmanFilter
            %
            KalmanFilter_(this.id, 'delete');
        end
        
        function init(this, dynamParams, measureParams, varargin)
            %INIT  Re-initializes Kalman filter. The previous content is destroyed
            %
            %    kf.init(dynamParams, measureParams, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __dynamParams__ Dimensionality of the state.
            % * __measureParams__ Dimensionality of the measurement.
            %
            % ## Options
            % * __ControlParams__ Dimensionality of the control vector.
            %
            % See also cv.KalmanFilter
            %
            KalmanFilter_(this.id, 'init', dynamParams, measureParams, varargin{:});
        end
        
        function s = predict(this, varargin)
            %PREDICT  Computes a predicted state
            %
            %    s = kf.predict('OptionName', optionValue, ...)
            %
            % ## Output
            % * __s__ Output predicted state.
            %
            % ## Options
            % * __Control__ The optional control input.
            %
            % See also cv.KalmanFilter
            %
            s = KalmanFilter_(this.id, 'predict', varargin{:});
        end
        
        function s = correct(this, measurement)
            %CORRECT  Updates the predicted state from the measurement
            %
            %    s = kf.correct(measurement)
            %
            % ## Input
            % * __measurement__ Input measurement.
            %
            % ## Output
            % * __s__ Output corrected state.
            %
            % See also cv.KalmanFilter
            %
            s = KalmanFilter_(this.id, 'correct', measurement);
        end
        
        function value = get.statePre(this)
            value = KalmanFilter_(this.id, 'statePre');
        end
        
        function set.statePre(this, value)
            KalmanFilter_(this.id, 'statePre', value);
        end
        
        function value = get.statePost(this)
            value = KalmanFilter_(this.id, 'statePost');
        end
        
        function set.statePost(this, value)
            KalmanFilter_(this.id, 'statePost', value);
        end
        
        function value = get.transitionMatrix(this)
            value = KalmanFilter_(this.id, 'transitionMatrix');
        end
        
        function set.transitionMatrix(this, value)
            KalmanFilter_(this.id, 'transitionMatrix', value);
        end
        
        function value = get.controlMatrix(this)
            value = KalmanFilter_(this.id, 'controlMatrix');
        end
        
        function set.controlMatrix(this, value)
            KalmanFilter_(this.id, 'controlMatrix', value);
        end
        
        function value = get.measurementMatrix(this)
            value = KalmanFilter_(this.id, 'measurementMatrix');
        end
        
        function set.measurementMatrix(this, value)
            KalmanFilter_(this.id, 'measurementMatrix', value);
        end
        
        function value = get.processNoiseCov(this)
            value = KalmanFilter_(this.id, 'processNoiseCov');
        end
        
        function set.processNoiseCov(this, value)
            KalmanFilter_(this.id, 'processNoiseCov', value);
        end
        
        function value = get.measurementNoiseCov(this)
            value = KalmanFilter_(this.id, 'measurementNoiseCov');
        end
        
        function set.measurementNoiseCov(this, value)
            KalmanFilter_(this.id, 'measurementNoiseCov', value);
        end
        
        function value = get.errorCovPre(this)
            value = KalmanFilter_(this.id, 'errorCovPre');
        end
        
        function set.errorCovPre(this, value)
            KalmanFilter_(this.id, 'errorCovPre', value);
        end
        
        function value = get.gain(this)
            value = KalmanFilter_(this.id, 'gain');
        end
        
        function set.gain(this, value)
            KalmanFilter_(this.id, 'gain', value);
        end
        
        function value = get.errorCovPost(this)
            value = KalmanFilter_(this.id, 'errorCovPost');
        end
        
        function set.errorCovPost(this, value)
            KalmanFilter_(this.id, 'errorCovPost', value);
        end
    end
    
end

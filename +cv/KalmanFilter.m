classdef KalmanFilter < handle
    %KALMANFILTER  Kalman filter class
    %
    % The class implements a standard Kalman filter
    % http://en.wikipedia.org/wiki/Kalman_filter, [Welch95]. However, you can
    % modify `transitionMatrix`, `controlMatrix`, and `measurementMatrix` to
    % get an extended Kalman filter functionality.
    %
    % ## Example
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
    %    p_pred = kf.predict();       % update internal state
    %    measure = [11;21];           % measurement
    %    p_est = kf.correct(measure); % correct
    %
    % ## References
    % [Welch95]:
    % > Greg Welch and Gary Bishop. An introduction to the kalman filter, 1995.
    % > http://www.cs.unc.edu/~welch/media/pdf/kalman_intro.pdf
    %
    % See also: cv.KalmanFilter.init, cv.KalmanFilter.predict,
    %   cv.KalmanFilter.correct, vision.KalmanFilter
    %

    properties (SetAccess = private)
        id % Object id
    end

    properties (Dependent)
        % predicted state `(x'(k)): x(k)=A*x(k-1)+B*u(k)`
        statePre
        % corrected state `(x(k)): x(k)=x'(k)+K(k)*(z(k)-H*x'(k))`
        statePost
        % state transition matrix `(A)`
        transitionMatrix
        % control matrix `(B)` (not used if there is no control)
        controlMatrix
        % measurement matrix `(H)`
        measurementMatrix
        % process noise covariance matrix `(Q)`
        processNoiseCov
        % measurement noise covariance matrix `(R)`
        measurementNoiseCov
        % priori error estimate covariance matrix
        % `(P'(k)): P'(k)=A*P(k-1)*At + Q`
        errorCovPre
        % Kalman gain matrix `(K(k)): K(k)=P'(k)*Ht*inv(H*P'(k)*Ht+R`)
        gain
        % posteriori error estimate covariance matrix
        % `(P(k)): P(k)=(I-K(k)*H)*P'(k)`
        errorCovPost
    end

    methods
        function this = KalmanFilter(varargin)
            %KALMANFILTER  KalmanFilter constructor
            %
            %    kf = cv.KalmanFilter()
            %    kf = cv.KalmanFilter(dynamParams, measureParams)
            %    kf = cv.KalmanFilter(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __dynamParams__ Dimensionality of the state.
            % * __measureParams__ Dimensionality of the measurement.
            %
            % ## Options
            % * __ControlParams__ Dimensionality of the control vector.
            %       default 0
            % * __Type__ Type of the created matrices that should be `single`
            %       or `double`. default `single`
            %
            % The constructor invokes the cv.KalmanFilter.init method to
            % initialize the object with the passed parameters.
            %
            % See also: cv.KalmanFilter, cv.KalmanFilter.init
            %
            this.id = KalmanFilter_(0, 'new');
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
            %    kf.init(dynamParams, measureParams)
            %    kf.init(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __dynamParams__ Dimensionality of the state.
            % * __measureParams__ Dimensionality of the measurement.
            %
            % ## Options
            % * __ControlParams__ Dimensionality of the control vector.
            %       default 0
            % * __Type__ Type of the created matrices that should be `single`
            %       or `double` (default).
            %
            % See also: cv.KalmanFilter.KalmanFilter
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
            % * __Control__ The optional input control. Not set by default
            %
            % See also: cv.KalmanFilter.correct
            %
            s = KalmanFilter_(this.id, 'predict', varargin{:});
        end

        function s = correct(this, measurement)
            %CORRECT  Updates the predicted state from the measurement
            %
            %    s = kf.correct(measurement)
            %
            % ## Input
            % * __measurement__ The measured system parameters.
            %
            % ## Output
            % * __s__ Output corrected state.
            %
            % See also: cv.KalmanFilter.predict
            %
            s = KalmanFilter_(this.id, 'correct', measurement);
        end
    end

    %% Getters/Setters
    methods
        function value = get.statePre(this)
            value = KalmanFilter_(this.id, 'get', 'statePre');
        end
        function set.statePre(this, value)
            KalmanFilter_(this.id, 'set', 'statePre', value);
        end

        function value = get.statePost(this)
            value = KalmanFilter_(this.id, 'get', 'statePost');
        end
        function set.statePost(this, value)
            KalmanFilter_(this.id, 'set', 'statePost', value);
        end

        function value = get.transitionMatrix(this)
            value = KalmanFilter_(this.id, 'get', 'transitionMatrix');
        end
        function set.transitionMatrix(this, value)
            KalmanFilter_(this.id, 'set', 'transitionMatrix', value);
        end

        function value = get.controlMatrix(this)
            value = KalmanFilter_(this.id, 'get', 'controlMatrix');
        end
        function set.controlMatrix(this, value)
            KalmanFilter_(this.id, 'set', 'controlMatrix', value);
        end

        function value = get.measurementMatrix(this)
            value = KalmanFilter_(this.id, 'get', 'measurementMatrix');
        end
        function set.measurementMatrix(this, value)
            KalmanFilter_(this.id, 'set', 'measurementMatrix', value);
        end

        function value = get.processNoiseCov(this)
            value = KalmanFilter_(this.id, 'get', 'processNoiseCov');
        end
        function set.processNoiseCov(this, value)
            KalmanFilter_(this.id, 'set', 'processNoiseCov', value);
        end

        function value = get.measurementNoiseCov(this)
            value = KalmanFilter_(this.id, 'get', 'measurementNoiseCov');
        end
        function set.measurementNoiseCov(this, value)
            KalmanFilter_(this.id, 'set', 'measurementNoiseCov', value);
        end

        function value = get.errorCovPre(this)
            value = KalmanFilter_(this.id, 'get', 'errorCovPre');
        end
        function set.errorCovPre(this, value)
            KalmanFilter_(this.id, 'set', 'errorCovPre', value);
        end

        function value = get.gain(this)
            value = KalmanFilter_(this.id, 'get', 'gain');
        end
        function set.gain(this, value)
            KalmanFilter_(this.id, 'set', 'gain', value);
        end

        function value = get.errorCovPost(this)
            value = KalmanFilter_(this.id, 'get', 'errorCovPost');
        end
        function set.errorCovPost(this, value)
            KalmanFilter_(this.id, 'set', 'errorCovPost', value);
        end
    end

end

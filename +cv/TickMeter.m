classdef TickMeter < handle
    %TICKMETER  A class to measure passing time
    %
    % The class computes passing time by counting the number of ticks per
    % second. That is, the following code computes the execution time in
    % seconds:
    %
    %    tm = cv.TickMeter();
    %    tm.start();
    %    % do something ...
    %    tm.stop();
    %    disp(tm.TimeSec)
    %
    % See also: tic, toc, cputime, timeit
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent, SetAccess = private)
        % counted ticks
        TimeTicks
        % passed time in microseconds
        TimeMicro
        % passed time in milliseconds
        TimeMilli
        % passed time in seconds
        TimeSec
        % internal counter value
        Counter
    end

    methods
        function this = TickMeter()
            %TICKMETER  the default constructor
            %
            %    obj = cv.TickMeter()
            %
            % See also: cv.TickMeter.start, cv.TickMeter.reset
            %
            this.id = TickMeter_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.TickMeter
            %
            if isempty(this.id), return; end
            TickMeter_(this.id, 'delete');
        end

        function start(this)
            %START  Starts counting ticks
            %
            %    obj.start()
            %
            % See also: cv.TickMeter.stop
            %
            TickMeter_(this.id, 'start');
        end

        function stop(this)
            %STOP  Stops counting ticks
            %
            %    obj.stop()
            %
            % See also: cv.TickMeter.start
            %
            TickMeter_(this.id, 'stop');
        end

        function reset(this)
            %RESET  Resets internal values
            %
            %    obj.reset()
            %
            % See also: cv.TickMeter.start
            %
            TickMeter_(this.id, 'reset');
        end
    end

    methods
        function value = get.TimeTicks(this)
            value = TickMeter_(this.id, 'get', 'TimeTicks');
        end

        function value = get.TimeMicro(this)
            value = TickMeter_(this.id, 'get', 'TimeMicro');
        end

        function value = get.TimeMilli(this)
            value = TickMeter_(this.id, 'get', 'TimeMilli');
        end

        function value = get.TimeSec(this)
            value = TickMeter_(this.id, 'get', 'TimeSec');
        end

        function value = get.Counter(this)
            value = TickMeter_(this.id, 'get', 'Counter');
        end
    end

end

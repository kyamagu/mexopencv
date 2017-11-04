classdef TickMeter < handle
    %TICKMETER  A class to measure passing time
    %
    % The class computes passing time by counting the number of ticks per
    % second. That is, the following code computes the execution time in
    % seconds:
    %
    %     tm = cv.TickMeter();
    %     tm.start();
    %     % do something ...
    %     tm.stop();
    %     disp(tm.TimeSec)
    %
    % It is also possible to compute the average time over multiple runs:
    %
    %     tm = cv.TickMeter();
    %     for i=1:100
    %         tm.start();
    %         % do something ...
    %         tm.stop();
    %     end
    %     fprintf('Average time in second per iteration is: %f\n', ...
    %         tm.TimeSec / double(tm.Counter))
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
            %     obj = cv.TickMeter()
            %
            % See also: cv.TickMeter.start, cv.TickMeter.reset
            %
            this.id = TickMeter_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.TickMeter
            %
            if isempty(this.id), return; end
            TickMeter_(this.id, 'delete');
        end

        function start(this)
            %START  Starts counting ticks
            %
            %     obj.start()
            %
            % See also: cv.TickMeter.stop
            %
            TickMeter_(this.id, 'start');
        end

        function stop(this)
            %STOP  Stops counting ticks
            %
            %     obj.stop()
            %
            % See also: cv.TickMeter.start
            %
            TickMeter_(this.id, 'stop');
        end

        function reset(this)
            %RESET  Resets internal values
            %
            %     obj.reset()
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

    methods (Static)
        function t = getTickCount();
            %GETTICKCOUNT  Returns the number of ticks.
            %
            %     t = cv.TickMeter.getTickCount()
            %
            % ## Output
            % * __t__ number of ticks.
            %
            % The function returns the number of ticks after a certain event
            % (for example, when the machine was turned on). It can be used to
            % initialize RNG or to measure a function execution time by
            % reading the tick count before and after the function call.
            %
            % See also: cv.TickMeter.getTickFrequency, cv.TickMeter
            %
            t = TickMeter_(0, 'getTickCount');
        end

        function f = getTickFrequency();
            %GETTICKFREQUENCY  Returns the number of ticks per second
            %
            %     f = cv.TickMeter.getTickFrequency()
            %
            % ## Output
            % * __f__ number of ticks per second.
            %
            % The function returns the number of ticks per second. That is,
            % the following code computes the execution time in seconds:
            %
            %     t = double(cv.TickMeter.getTickCount());
            %     % do something ...
            %     t = (double(cv.TickMeter.getTickCount()) - t) / cv.TickMeter.getTickFrequency();
            %
            % See also: cv.TickMeter.getTickCount, cv.TickMeter
            %
            f = TickMeter_(0, 'getTickFrequency');
        end

        function t = getCPUTickCount();
            %GETCPUTICKCOUNT  Returns the number of CPU ticks
            %
            %     t = cv.TickMeter.getCPUTickCount()
            %
            % ## Output
            % * __t__ number of CPU ticks.
            %
            % The function returns the current number of CPU ticks on some
            % architectures (such as x86, x64, PowerPC). On other platforms
            % the function is equivalent to cv.TickMeter.getTickCount. It can
            % also be used for very accurate time measurements, as well as for
            % RNG initialization. Note that in case of multi-CPU systems a
            % thread, from which cv.TickMeter.getCPUTickCount is called, can
            % be suspended and resumed at another CPU with its own counter.
            % So, theoretically (and practically) the subsequent calls to the
            % function do not necessary return the monotonically increasing
            % values. Also, since modern CPUs varies the CPU frequency
            % depending on the load, the number of CPU clocks spent in some
            % code cannot be directly converted to time units. Therefore,
            % cv.TickMeter.getTickCount is generally a preferable solution for
            % measuring execution time.
            %
            % See also: cv.TickMeter.getTickFrequency
            %
            t = TickMeter_(0, 'getCPUTickCount');
        end
    end

end

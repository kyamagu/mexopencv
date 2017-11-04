classdef TestTickMeter
    %TestTickMeter

    methods (Static)
        function test_1
            tm = cv.TickMeter();
            tm.reset();
            tm.start();
            pause(0.1);
            tm.stop();
            validateattributes(tm.TimeTicks, {'int64'}, {'scalar'});
            validateattributes(tm.TimeMicro, {'double'}, {'scalar'});
            validateattributes(tm.TimeMilli, {'double'}, {'scalar'});
            validateattributes(tm.TimeSec, {'double'}, {'scalar'});
            validateattributes(tm.Counter, {'int64'}, {'scalar'});
            %assert(abs(tm.TimeSec - 0.1) < 0.02);
        end

        function test_2
            t1 = cv.TickMeter.getTickCount();
            pause(0.1);
            t2 = cv.TickMeter.getTickCount();
            f = cv.TickMeter.getTickFrequency();
            tsec = double(t2 - t1) / f;
            validateattributes(t1, {'int64'}, {'scalar'});
            validateattributes(t2, {'int64'}, {'scalar'});
            validateattributes(f, {'double'}, {'scalar'});
            %assert(abs(tsec - 0.1) < 0.02);
        end
    end

end

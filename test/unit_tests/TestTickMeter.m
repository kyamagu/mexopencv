classdef TestTickMeter
    %TestTickMeter

    methods (Static)
        function test_1
            tm = cv.TickMeter();
            tm.reset();
            tm.start();
            pause(0.2);
            tm.stop();
            validateattributes(tm.TimeTicks, {'int64'}, {'scalar'});
            validateattributes(tm.TimeMicro, {'double'}, {'scalar'});
            validateattributes(tm.TimeMilli, {'double'}, {'scalar'});
            validateattributes(tm.TimeSec, {'double'}, {'scalar'});
            validateattributes(tm.Counter, {'int64'}, {'scalar'});
            %assert(abs(tm.TimeSec - 0.2) < 0.02);
        end
    end

end

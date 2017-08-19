classdef TestLineIterator
    %TestLineIterator

    methods (Static)
        function test_1
            img = zeros(200, 200, 'uint8');
            [pts, count] = cv.LineIterator(img, [150 100], [50 60], ...
                'Connectivity',8, 'LeftToRight',true);
            validateattributes(count, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative'});
            validateattributes(pts, {'numeric'}, ...
                {'integer', 'size',[count 2]});
        end

        function test_error_argnum
            try
                cv.LineIterator();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

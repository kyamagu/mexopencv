classdef TestContourArea
    %TestContourArea

    methods (Static)
        function test_1
            curve = {[0 0], [1 0], [2 2], [3 3], [3 4]};
            a = cv.contourArea(curve);
            validateattributes(a, {'double'}, {'scalar'}, ...
                'cv.contourArea', 'a');
        end

        function test_2
            curve = [0 0; 1 0; 2 2; 3 3; 3 4];
            a = cv.contourArea(curve, 'Oriented',false);
            validateattributes(a, {'double'}, {'scalar'}, ...
                'cv.contourArea', 'a');
        end

        function test_error_1
            try
                cv.contourArea();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

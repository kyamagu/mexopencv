classdef TestBoxPoints
    %TestBoxPoints

    methods (Static)
        function test_1
            rrect = struct('center',[10,20], 'size',[5,6], 'angle',30);
            pts = cv.boxPoints(rrect);
            validateattributes(pts, {'numeric'}, {'2d', 'size',[4 2]});
        end

        function test_error_argnum
            try
                cv.boxPoints();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

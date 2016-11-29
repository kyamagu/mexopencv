classdef TestSampsonDistance
    %TestSampsonDistance

    methods (Static)
        function test_1
            pt1 = [rand(1,2) 1];
            pt2 = [rand(1,2) 1];
            F = eye(3);
            sd = cv.sampsonDistance(pt1, pt2, F);
            validateattributes(sd, {'double'}, {'scalar'});
        end

        function test_error_argnum
            try
                cv.sampsonDistance();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

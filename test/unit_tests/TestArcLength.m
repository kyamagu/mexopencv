classdef TestArcLength
    %TestArcLength

    methods (Static)
        function test_1
            curve = {[0 0] ,[1 0] ,[2 2] ,[3 3] ,[3 4]};
            len = cv.arcLength(curve, 'Closed',false);
            validateattributes(len, {'double'}, {'scalar'});
        end

        function test_2
            curve = [0 0; 1 0; 2 2; 3 3; 3 4];
            len = cv.arcLength(curve, 'Closed',true);
            validateattributes(len, {'double'}, {'scalar'});
        end

        function test_error_1
            try
                cv.arcLength();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

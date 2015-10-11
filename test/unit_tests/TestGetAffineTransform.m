classdef TestGetAffineTransform
    %TestGetAffineTransform

    methods (Static)
        function test_1
            ref = [0, 1, 0; -1, 0, 1];
            src = [0.0, 1.0; 1.0, 1.0; 1.0, 0.0];
            dst = [1.0, 1.0; 1.0, 0.0; 0.0, 0.0];
            t = cv.getAffineTransform(src, dst);
            validateattributes(t, {'numeric'}, {'size',[2 3]});
            assert(isequal(t,ref));
        end

        function test_2
            ref = [0, 1, 0; -1, 0, 1];
            src = num2cell([0.0, 1.0; 1.0, 1.0; 1.0, 0.0], 2);
            dst = num2cell([1.0, 1.0; 1.0, 0.0; 0.0, 0.0], 2);
            t = cv.getAffineTransform(src, dst);
            validateattributes(t, {'numeric'}, {'size',[2 3]});
            assert(isequal(t,ref));
        end

        function test_error_1
            try
                cv.getAffineTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

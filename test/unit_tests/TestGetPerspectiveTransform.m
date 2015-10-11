classdef TestGetPerspectiveTransform
    %TestGetPerspectiveTransform

    methods (Static)
        function test_1
            ref = [0, 1, 0; -1, 0, 1; 0, 0, 1];
            src = [0.0, 1.0; 1.0, 1.0; 1.0, 0.0; 0.25, 0.25];
            dst = [1.0, 1.0; 1.0, 0.0; 0.0, 0.0; 0.25, 0.75];
            t = cv.getPerspectiveTransform(src, dst);
            validateattributes(t, {'numeric'}, {'size',[3 3]});
            assert(all(abs(t(:)-ref(:)) < 1e-10));
        end

        function test_2
            ref = [0, 1, 0; -1, 0, 1; 0, 0, 1];
            src = num2cell([0.0, 1.0; 1.0, 1.0; 1.0, 0.0; 0.25, 0.25], 2);
            dst = num2cell([1.0, 1.0; 1.0, 0.0; 0.0, 0.0; 0.25, 0.75], 2);
            t = cv.getPerspectiveTransform(src, dst);
            validateattributes(t, {'numeric'}, {'size',[3 3]});
            assert(all(abs(t(:)-ref(:)) < 1e-10));
        end

        function test_error_1
            try
                cv.getPerspectiveTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

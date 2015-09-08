classdef TestApproxPolyDP
    %TestApproxPolyDP

    methods (Static)
        function test_1
            curve = {[0 0], [1 1], [2 2], [3 3], [4 4]};
            approxCurve = cv.approxPolyDP(curve);
            assert(iscell(approxCurve));
            if ~isempty(approxCurve)
                assert(all(cellfun(@numel, approxCurve) == 2));
            end
        end

        function test_2
            curve = single([0 0; 10 0; 10 10; 5 4]);
            approxCurve = cv.approxPolyDP(curve, 'Epsilon',5, 'Closed',true);
            assert(isnumeric(approxCurve) && isfloat(approxCurve));
            if ~isempty(approxCurve)
                assert(ismatrix(approxCurve) && size(approxCurve,2)==2);
            end
        end

        function test_3
            curve = int32([0 0; 1 1; 2 2; 3 3; 4 4]);
            approxCurve = cv.approxPolyDP(curve);
            assert(isnumeric(approxCurve) && isinteger(approxCurve));
        end

        function test_error_1
            try
                cv.approxPolyDP();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

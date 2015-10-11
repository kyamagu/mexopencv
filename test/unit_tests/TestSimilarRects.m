classdef TestSimilarRects
    %TestSimilarRects

    methods (Static)
        function test_cell
            r1 = [10 10 20 20];
            r2 = [12 12 21 21];
            tf = cv.SimilarRects(r1, r2, 'EPS',0.2);
            validateattributes(tf, {'logical'}, {'scalar'});
        end

        function test_error_1
            try
                cv.SimilarRects();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

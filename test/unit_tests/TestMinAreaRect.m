classdef TestMinAreaRect
    %TestMinAreaRect
    properties (Constant)
        pts = [0 0; 1 0; 2 2; 3 3; 3 4];
    end

    methods (Static)
        function test_1
            box = cv.minAreaRect(TestMinAreaRect.pts);
            validateattributes(box, {'struct'}, {'scalar'});
            assert(all(ismember({'center','size','angle'}, fieldnames(box))));
        end

        function test_2
            box = cv.minAreaRect(num2cell(TestMinAreaRect.pts,2));
            validateattributes(box, {'struct'}, {'scalar'});
            assert(all(ismember({'center','size','angle'}, fieldnames(box))));
        end

        function test_error_1
            try
                cv.minAreaRect();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

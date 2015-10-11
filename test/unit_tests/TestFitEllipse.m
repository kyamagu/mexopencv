classdef TestFitEllipse
    %TestFitEllipse

    methods (Static)
        function test_1
            % noisy circle, numeric matrix
            t = linspace(0, 2*pi, 50).';
            points = bsxfun(@plus, [cos(t) sin(t)]*100, [150 150]);
            points = bsxfun(@plus, points, randn(size(points))*10);

            rct = cv.fitEllipse(points);
            validateattributes(rct, {'struct'}, {'scalar'});
            assert(all(ismember({'center','size','angle'}, fieldnames(rct))));

            % cell array of points
            points = num2cell(points,2);
            rct = cv.fitEllipse(points);
            validateattributes(rct, {'struct'}, {'scalar'});
            assert(all(ismember({'center','size','angle'}, fieldnames(rct))));
        end

        function test_error_1
            try
                cv.fitEllipse();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

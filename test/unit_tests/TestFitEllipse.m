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

        function test_methods
            % noisy circle
            t = linspace(0, 2*pi, 50).';
            points = bsxfun(@plus, [cos(t) sin(t)]*100, [150 150]);
            points = bsxfun(@plus, points, randn(size(points))*10);

            algs = {'Linear', 'Direct', 'AMS'};
            for i=1:numel(algs)
                rct = cv.fitEllipse(points, 'Method',algs{i});
                validateattributes(rct, {'struct'}, {'scalar'});
            end
        end

        function test_error_argnum
            try
                cv.fitEllipse();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

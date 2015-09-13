classdef TestFindHomography
    %TestFindHomography

    methods (Static)
        function test_1
            % generate N random points, transform them using a reference H
            N = 12;
            H = [0.75 -0.2 100; 0.1 0.8 50; 1e-5 1e-4 1];
            p1 = bsxfun(@times, rand(N,2), [480 640]);
            p2 = cv.perspectiveTransform(p1, H);

            % introduce small noise in points
            p1 = round(p1 + randn(size(p1)));
            p2 = round(p2 + randn(size(p2)));

            % introduce an extreme outlier (to test robust estimators)
            p2(1,1) = 1000;

            % estimate homography
            estMethods = {0, 'Ransac', 'LMedS', 'Rho'};
            for i=1:numel(estMethods)
                [HH, mask] = cv.findHomography(p1, p2, ...
                    'Method',estMethods{i}, 'MaxIters',2000, ...
                    'RansacReprojThreshold',3.0, 'Confidence',0.995);
                validateattributes(HH, {'single' 'double'}, {'size',[3 3]});
                validateattributes(mask, {'uint8'}, ...
                    {'vector', 'numel',N, 'binary'});
                err = norm(H-HH);
                %if i>1, assert(mask(1)==0); end
            end
        end

        function test_error_1
            try
                cv.findHomography();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

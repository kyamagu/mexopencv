classdef TestMahalanobis
    %TestMahalanobis

    methods (Static)
        function test_1
            v1 = rand(1,3);
            v2 = rand(1,3);
            C = rand(3,3);
            C = C * C' + eye(3);
            d = cv.Mahalanobis(v1, v2, inv(C));
            validateattributes(d, {'double'}, {'scalar'});
        end

        function test_2
            v1 = randn(1,4);
            v2 = randn(1,4);
            C = eye(4);  % identity cov matrix
            d = cv.Mahalanobis(v1, v2, C);
            validateattributes(d, {'double'}, {'scalar'});
            %assert(d == norm(v1-v2)); % equivalent to Eucliden dist
        end

        function test_error_1
            try
                cv.Mahalanobis();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

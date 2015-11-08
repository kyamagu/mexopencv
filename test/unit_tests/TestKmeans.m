classdef TestKmeans
    %TestKmeans

    methods (Static)
        function test_1
            X = randn(100,3);
            [labels,centers,d] = cv.kmeans(X,5);
            assert(isvector(labels) && numel(labels)==100);
            assert(ismatrix(centers) && isequal(size(centers), [5 3]));
            assert(isscalar(d));
        end

        function test_2
            X = randn(100,3);
            [labels,centers] = cv.kmeans(X, 5, 'Initialization','PP', 'Attempts',10, ...
                'Criteria',struct('type','Count+EPS', 'maxCount',100, 'epsilon',1e-6));
        end

        function test_3
            X = [randn(100,3)-1; randn(100,3)+1];
            labels0 = [ones(100,1)*0; ones(100,1)*1];
            [labels,centers] = cv.kmeans(X, 2, 'InitialLabels',labels0);
        end

        function test_error_1
            try
                cv.kmeans();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

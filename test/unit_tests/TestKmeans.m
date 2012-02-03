classdef TestKmeans
    %TestKmeans
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            X = randn(100,3);
            [labels,centers,d] = cv.kmeans(X,5);
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


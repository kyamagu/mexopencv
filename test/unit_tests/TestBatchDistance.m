classdef TestBatchDistance
    %TestBatchDistance
    properties (Constant)
    end

    methods (Static)
        function test_1
            X = rand(100,4,'single');
            D = cv.batchDistance(X, X);
        end

        function test_2
            X = rand(100,4);
            D = cv.batchDistance(X, X, 'NormType','L1');
        end

        function test_3
            X = rand(100,4);
            Y = rand(100,4);
            [D,nidx] = cv.batchDistance(X, Y, 'K',2);
        end

        function test_error_1
            try
                cv.batchDistance();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

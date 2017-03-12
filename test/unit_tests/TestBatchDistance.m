classdef TestBatchDistance
    %TestBatchDistance

    methods (Static)
        function test_1
            X = rand(40,4,'single');
            D = cv.batchDistance(X, X);
            assert(isequal(size(D), [40 40]));
        end

        function test_2
            X = rand(40,4);
            Y = rand(20,4);
            [D,nidx] = cv.batchDistance(X, Y, 'NormType','L1');
            assert(isequal(size(D), [40 20]));
            if ~mexopencv.isOctave()
                %HACK: https://savannah.gnu.org/bugs/index.php?45319
                assert(isempty(nidx))
            end
        end

        function test_3
            X = rand(40,4);
            Y = rand(20,4);
            [D,nidx] = cv.batchDistance(X, Y, 'K',2);
            assert(isequal(size(D), size(nidx), [40 2]));
            assert(isinteger(nidx));
        end

        function test_error_argnum
            try
                cv.batchDistance();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

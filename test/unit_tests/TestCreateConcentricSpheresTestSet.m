classdef TestCreateConcentricSpheresTestSet
    %TestCreateConcentricSpheresTestSet

    methods (Static)
        function test_1
            nsamples = 50;
            nfeatures = 2;
            nclasses = 2;
            [samples,sampIDX] = cv.createConcentricSpheresTestSet(...
                nsamples, nfeatures, nclasses);
            validateattributes(samples, {'numeric'}, {'size',[nsamples nfeatures]});
            validateattributes(sampIDX, {'numeric'}, ...
                {'vector', 'numel',nsamples, 'integer', 'nonnegative' '<',nclasses});
            %gscatter(samples(:,1), samples(:,2), sampIDX)
        end

        function test_error_argnum
            try
                cv.createConcentricSpheresTestSet();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

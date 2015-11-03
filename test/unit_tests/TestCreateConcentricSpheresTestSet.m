classdef TestCreateConcentricSpheresTestSet
    %TestCreateConcentricSpheresTestSet

    methods (Static)
        function test_1
            %TODO: https://github.com/Itseez/opencv/issues/5469
            if true
                disp('SKIP');
                return;
            end

            nsamples = 50;
            nfeatures = 2;
            nclasses = 2;
            [samples,sampIDX] = cv.createConcentricSpheresTestSet(...
                nsamples, nfeatures, nclasses);
            validateattributes(samples, {'numeric'}, {'size',[nsamples nfeatures]});
            validateattributes(sampIDX, {'numeric'}, ...
                {'vector', 'numel',nsamples, 'integer', 'nonnegative' '<',nclasses});
        end

        function test_error_1
            try
                cv.createConcentricSpheresTestSet();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

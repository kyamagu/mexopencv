classdef TestRandMVNormal
    %TestRandMVNormal

    methods (Static)
        function test_1
            %TODO: https://github.com/Itseez/opencv/issues/5469
            if true
                disp('SKIP');
                return;
            end

            d = 3;
            mu = rand(1,d);
            sigma = eye(d);
            nsamples = 50;
            samples = cv.randMVNormal(mu, sigma, nsamples);
            validateattributes(samples, {'numeric'}, {'size',[nsamples d]});
        end

        function test_error_1
            try
                cv.randMVNormal();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

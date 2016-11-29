classdef TestRandMVNormal
    %TestRandMVNormal

    methods (Static)
        function test_1
            d = 3;
            mu = rand(1,d);
            sigma = eye(d);
            nsamples = 50;
            samples = cv.randMVNormal(mu, sigma, nsamples);
            validateattributes(samples, {'numeric'}, {'size',[nsamples d]});
            mean(samples);  % should be close to mu
            cov(samples);   % should be close to sigma
        end

        function test_error_argnum
            try
                cv.randMVNormal();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

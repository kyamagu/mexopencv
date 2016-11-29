classdef TestCovarianceEstimation
    %TestCovarianceEstimation

    methods (Static)
        function test_1
            M = rand(50,50,'single');
            wsz = [5 5];
            C = cv.covarianceEstimation(M, wsz);
            validateattributes(C, {'single'}, ...
                {'size',[prod(wsz) prod(wsz) 2]});
            C = complex(C(:,:,1), C(:,:,2));
        end

        function test_2
            M = single(complex(rand(50,50), rand(50,50)));
            M = cat(3, real(M), imag(M));
            wsz = [5 5];
            C = cv.covarianceEstimation(M, wsz);
            validateattributes(C, {'single'}, ...
                {'size',[prod(wsz) prod(wsz) 2]});
            C = complex(C(:,:,1), C(:,:,2));
        end

        function test_error_argnum
            try
                cv.covarianceEstimation();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

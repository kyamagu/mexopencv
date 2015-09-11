classdef TestGetGaussianKernel
    %TestScharr

    methods (Static)
        function test_1
            kernel = cv.getGaussianKernel();
            validateattributes(kernel, {'double'}, {'vector', 'numel',5});
        end

        function test_2
            kernel = cv.getGaussianKernel(...
                'KSize',5, 'Sigma',-1, 'KType','double');
            validateattributes(kernel, {'double'}, {'vector', 'numel',5});
        end

        function test_error_1
            try
                cv.getGaussianKernel('foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

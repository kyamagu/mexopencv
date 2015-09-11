classdef TestGetDerivKernels
    %TestScharr

    methods (Static)
        function test_1
            [kx,ky] = cv.getDerivKernels();
            validateattributes(kx, {'single'}, {'vector', 'numel',3});
            validateattributes(ky, {'single'}, {'vector', 'numel',3});
        end

        function test_2
            [kx,ky] = cv.getDerivKernels('KSize',7, ...
                'Normalize',true, 'KType','double');
            validateattributes(kx, {'double'}, {'vector', 'numel',7});
            validateattributes(ky, {'double'}, {'vector', 'numel',7});
        end

        function test_3
            [kx,ky] = cv.getDerivKernels('KSize','Scharr', ...
                'Dx',1, 'Dy',0);
            validateattributes(kx, {'single'}, {'vector', 'numel',3});
            validateattributes(ky, {'single'}, {'vector', 'numel',3});
        end

        function test_error_1
            try
                cv.getDerivKernels('foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

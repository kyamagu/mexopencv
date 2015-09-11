classdef TestGetGaborKernel
    %TestGetGaborKernel

    methods (Static)
        function test_1
            kernel = cv.getGaborKernel('KSize',[21 21]);
            validateattributes(kernel, {'double'}, {'2d', 'size',[21 21]});
        end

        function test_2
            kernel = cv.getGaborKernel('KSize',[19 21], 'Sigma',5, ...
                'Theta',pi/4, 'Lambda',50, 'Gamma',0.5, 'Psi',pi/2, ...
                'KType','double');
            validateattributes(kernel, {'double'}, {'2d', 'size',[21 19]});
        end

        function test_error_1
            try
                cv.getGaborKernel('foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestMatMulDeriv
    %TestMatMulDeriv

    methods (Static)
        function test_1
            klass = {'double', 'single'};
            for k=1:numel(klass)
                A = randn(5,3, klass{k});
                B = randn(3,4, klass{k});
                AB = A*B;
                sza = size(A);
                szb = size(B);
                [dABdA,dABdB] = cv.matMulDeriv(A,B);
                validateattributes(dABdA, {class(A)}, ...
                    {'size',[sza(1)*szb(2) prod(sza)]});
                validateattributes(dABdB, {class(A)}, ...
                    {'size',[sza(1)*szb(2) prod(szb)]});
            end
        end

        function test_error_1
            try
                cv.matMulDeriv();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

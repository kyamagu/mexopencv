classdef TestMulSpectrums
    %TestMulSpectrums

    methods (Static)
        function test_1d_real
            x = sin(linspace(0, 6*pi, 10));
            y = cv.dft(x);
            c = cv.mulSpectrums(y, y);
            validateattributes(c, {class(y)}, {'size',size(y)});
        end

        function test_1d_complex
            x = sin(linspace(0, 6*pi, 10));
            y = cv.dft(x, 'ComplexOutput',true);
            c = cv.mulSpectrums(y, y);
            validateattributes(c, {class(y)}, {'size',size(y)});
        end

        function test_convolution_theorem
            x = sin(linspace(0, 6*pi, 200));  % signal
            y = [0 0.5 1 0.5 0];              % kernel
            N = numel(x);
            M = numel(y);

            % convolution theorem: fft(conv(f,g)) = fft(f) .* fft(g)
            if false
                y1 = ifft(fft(x) .* fft(y,N));
            else
                % zero-pad convolution kernel to array length
                yy = y;
                yy(N) = 0;

                a = cv.dft(x);
                b = cv.dft(yy, 'NonzeroRows',M);
                c = cv.mulSpectrums(a, b);
                y1 = cv.dft(c, 'Inverse',true, 'Scale',true, 'NonzeroRows',N-M);
            end
            y2 = conv(x,y);

            % compare
            err = norm(y1(M+1:N) - y2(M+1:N));
        end

        function test_error_argnum
            try
                cv.mulSpectrums();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

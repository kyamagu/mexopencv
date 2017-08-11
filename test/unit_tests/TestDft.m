classdef TestDft
    %TestDft

    methods (Static)
        function test_1d_real
            % 1x100 real signal
            x = sin(linspace(0, 6*pi, 100));

            % 1D DFT
            y = cv.dft(x);
            validateattributes(y, {class(x)}, {'vector', 'numel',numel(x)});

            % inverse transform
            xx = cv.dft(y, 'Inverse',true, 'Scale',true);
            validateattributes(xx, {class(x)}, {'vector', 'numel',numel(x)});

            err = norm(x - xx);
        end

        function test_1d_complex
            % 1x100 complex signal
            x = sin(linspace(0, 6*pi, 100)); % real
            x(:,:,2) = 0;                    % imag

            % 1D DFT
            y = cv.dft(x, 'ComplexInput',true);
            validateattributes(y, {class(x)}, {'size',size(x)});

            % inverse transform
            xx = cv.dft(y, 'Inverse',true, 'Scale',true);
            validateattributes(xx, {class(x)}, {'size',size(x)});

            err = norm(x(:) - xx(:));
        end

        function test_2d
            % image (256x256)
            img = cv.imread(fullfile(mexopencv.root(), 'test', 'blox.jpg'), ...
                'Grayscale',true);
            I = double(img);

            % 2D DFT
            J = cv.dft(I, 'ComplexOutput',true);
            validateattributes(J, {class(I)}, {'size',[size(I) 2]});

            % 2D DFT is simply the 1D DFT, performed along the rows and then
            % along the columns: fft2(I) = fft(fft(I).').'
            J2 = cv.dft(I, 'Rows',true, 'ComplexOutput',true);
            J2 = permute(J2, [2 1 3]);
            J2 = cv.dft(J2, 'Rows',true, 'ComplexOutput',true);
            J2 = permute(J2, [2 1 3]);
            %assert(norm(J(:) - J2(:)) < 1e-9);

            % inverse transform
            II = cv.dft(J, 'Inverse',true, 'Scale',true, 'RealOutput',true);
            validateattributes(II, {class(I)}, {'2d', 'size',size(I)});
            err = norm(I - II);
        end

        function test_ccs_1d
            % real 1D vector
            if true
                N = 100; % even case
            else
                N = 101; % odd case
            end
            x = sin(linspace(0, 6*pi, N));
            x = x + randn(size(x));

            % 1D DFT (packed CCS format)
            y = cv.dft(x);

            % un-pack CCS into full complex array (both even/odd length cases)
            if rem(N, 2) == 0
                dc = y(1);           % DC component
                pos = y(2:2:end-1);  % positive frequencies (real part)
                neg = y(3:2:end-1);  % negative frequencies (imaginary part)
                nyq = y(end);        % nyquist frequency
                yy = cat(3, ...
                    [dc, pos, nyq, fliplr(pos)], ...
                    [0, neg, 0, fliplr(-neg)]);
            else
                dc = y(1);
                pos = y(2:2:end);
                neg = y(3:2:end);
                nyq = [];  % no nyquist
                yy = cat(3, ...
                    [dc, pos, fliplr(pos)], ...
                    [0, neg, fliplr(-neg)]);
            end

            % compare
            y2 = cv.dft(x, 'ComplexOutput',true);
            assert(isequal(y2, yy));

            % compare against builtin FFT function
            yy = complex(yy(:,:,1), yy(:,:,2));
            y3 = fft(x);
            %assert(norm(y3 - yy) < 1e-9);
        end

        function test_ccs_2d
            %TODO
            error('mexopencv:testskip', 'todo');
        end

        function test_error_argnum
            try
                cv.dft();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

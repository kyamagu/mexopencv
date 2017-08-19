classdef TestDct
    %TestDct

    methods (Static)
        function test_1d
            % noisy signal 1x1000
            fs = 1000;
            t = 0:1/fs:1-1/fs;
            x = sin(2*pi*25*t) + randn(size(t))/10;
            assert(rem(numel(x),2) == 0, 'only even-size arrays');

            % 1D DCT
            y = cv.dct(x);
            validateattributes(y, {class(x)}, {'vector', 'numel',numel(x)});

            % approximation (discard small high-frequency components)
            y(abs(y) < 1) = 0;
            % inverse transform
            xx = cv.dct(y, 'Inverse',true);
            validateattributes(xx, {class(x)}, {'vector', 'numel',numel(x)});
        end

        function test_2d
            % image (256x256)
            img = cv.imread(fullfile(mexopencv.root(), 'test', 'blox.jpg'), ...
                'Grayscale',true);
            I = double(img);

            % 2D DCT
            J = cv.dct(I);
            validateattributes(J, {class(I)}, {'2d', 'size',size(I)});

            % 2D DCT is simply the 1D DCT, performed along the rows and then
            % along the columns
            J2 = cv.dct(cv.dct(I, 'Rows',true).', 'Rows',true).';
            %assert(norm(J - J2) < 1e-9);

            % approximation (discard small high-frequency components)
            J(abs(J) < 10) = 0;
            % inverse transform
            II = cv.dct(J, 'Inverse',true);
            validateattributes(II, {class(I)}, {'2d', 'size',size(I)});
        end

        function test_compare_1d
            % we use DCT/IDCT from Signal Processing Toolbox
            if ~mexopencv.require('signal')
                error('mexopencv:testskip', 'toolbox');
            end

            x = (1:100) + 50*cos((1:100)*2*pi/40);

            y1 = cv.dct(x);
            y2 = dct(x);
            err = norm(y1 - y2);

            x1 = cv.dct(y1, 'Inverse',true);
            x2 = idct(y2);
            err = norm(x1 - x2);
        end

        function test_compare_2d
            % we use DCT2/IDCT2 from Signal Processing Toolbox
            if ~mexopencv.require('signal')
                error('mexopencv:testskip', 'toolbox');
            end

            img = cv.imread(fullfile(mexopencv.root(), 'test', 'blox.jpg'), ...
                'Grayscale',true);
            I = double(img);

            J1 = cv.dct(I);
            J2 = dct2(I);
            err = norm(J1 - J2);

            I1 = cv.dct(J1, 'Inverse',true);
            I2 = idct2(J2);
            err = norm(I1 - I2);
        end

        function test_error_argnum
            try
                cv.dct();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

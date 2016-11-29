classdef TestMultiply
    %TestMultiply

    methods (Static)
        function test_rbg_image
            img = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'ReduceScale',2);
            img = img/2;

            out = cv.multiply(img, img);
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_multiply(img, img);
                assert(isequal(out, expected));
            end

            out = cv.multiply(img, img, 'DType','uint16');
            validateattributes(out, {'uint16'}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_multiply(img, img, 'uint16');
                assert(isequal(out, expected));
            end
        end

        function test_2d_matrix
            A = uint8([10 35; 20 25]);
            B = uint8([10 10; 20 10]);

            out = cv.multiply(A, B);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([100 255; 255 250]);  % A .* B
            assert(isequal(out, expected));

            out = cv.multiply(A, 2);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = A .* 2;
            assert(isequal(out, expected));

            out = cv.multiply(2, A);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = 2 .* A;
            assert(isequal(out, expected));

            out = cv.multiply(2, 2);
            validateattributes(out, {'double'}, {'scalar'});
            expected = 2 * 2;
            assert(isequal(out, expected));

            out = cv.multiply(A, B, 'Scale',2);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([200 255; 255 255]);  % 2*A .* B
            assert(isequal(out, expected));
        end

        function test_output_depth
            out = cv.multiply(int16(20), uint8(20), 'DType','single');
            validateattributes(out, {'single'}, {'scalar'});
            assert(isequal(out, 400));
        end

        function test_saturation
            out = cv.multiply(uint8(20), uint8(30), 'DType','uint8');
            validateattributes(out, {'uint8'}, {'scalar'});
            assert(isequal(out, 255));

            out = cv.multiply(uint8(20), uint8(30), 'DType','uint16');
            validateattributes(out, {'uint16'}, {'scalar'});
            assert(isequal(out, 600));

            % saturation not applied for int32 (result overflows)
            out = cv.multiply(int32(50000), int32(50000), 'DType','int32');
            %validateattributes(out, {'int32'}, {'scalar', '<',0});

            % unlike MATLAB where result saturates
            %out = int32(50000) * int32(50000);
            %assert(isequal(out, intmax('int32')));
        end

        function test_error_argnum
            try
                cv.multiply();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_multiply(src1, src2, dtype)
    %MY_MULTIPLY  Similar to cv.multiply using immultiply from IPT

    if nargin < 3, dtype = class(src1); end

    % multiply two images with specified output class
    out = immultiply(cast(src1, dtype), cast(src2, dtype));
end

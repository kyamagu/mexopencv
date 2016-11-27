classdef TestDivide
    %TestDivide

    methods (Static)
        function test_rbg_image
            img = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'ReduceScale',2);

            out = cv.divide(img, img/2);
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_divide(img, img/2);
                assert(isequal(out, expected));
            end

            out = cv.divide(img, img/2, 'DType','uint16');
            validateattributes(out, {'uint16'}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_divide(img, img/2, 'uint16');
                assert(isequal(out, expected));
            end
        end

        function test_2d_matrix
            A = uint8([10 35; 20 30]);
            B = uint8([10 10; 30  7]);

            out = cv.divide(A, B);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([1 4; 1 4]);  % A ./ B
            assert(isequal(out, expected));

            out = cv.divide(A, 2);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = A ./ 2;
            assert(isequal(out, expected));

            out = cv.divide(2, A);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = 2 ./ A;
            assert(isequal(out, expected));

            out = cv.divide(2, 2);
            validateattributes(out, {'double'}, {'scalar'});
            expected = 2 / 2;
            assert(isequal(out, expected));

            out = cv.divide(A, B, 'Scale',2);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([2 7; 1 9]);  % 2*A ./ B
            assert(isequal(out, expected));
        end

        function test_output_depth
            out = cv.divide(int16(30), uint8(20), 'DType','single');
            validateattributes(out, {'single'}, {'scalar'});
            assert(isequal(out, 1.5));
        end

        function test_saturation
            out = cv.divide(uint8(200), int16(-2), 'DType','uint8');
            validateattributes(out, {'uint8'}, {'scalar'});
            assert(isequal(out, 0));

            out = cv.divide(uint8(200), int16(-2), 'DType','int16');
            validateattributes(out, {'int16'}, {'scalar'});
            assert(isequal(out, -100));

            % saturation not applied for int32 (result overflows)
            out = cv.divide(int32(1073741824), 0.5, 'DType','int32');
            %validateattributes(out, {'int32'}, {'scalar', '<',0});

            % unlike MATLAB where result saturates
            %out = int32(1073741824) / 0.5;
            %assert(isequal(out, intmax('int32')));
        end

        function test_error_argnum
            try
                cv.divide();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_divide(src1, src2, dtype)
    %MY_DIVIDE  Similar to cv.divide using imdivide from IPT

    if nargin < 3, dtype = class(src1); end

    % divide two images with specified output class
    out = imdivide(cast(src1, dtype), cast(src2, dtype));
end

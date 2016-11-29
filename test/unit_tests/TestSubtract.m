classdef TestSubtract
    %TestSubtract

    methods (Static)
        function test_rgb_image
            img = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'ReduceScale',2);
            [h,w,~] = size(img);
            mask = false(h,w);
            mask(100:h-100,100:w-100) = true;

            out = cv.subtract(img, img/2);
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_subtract(img, img/2);
                assert(isequal(out, expected));
            end

            out = cv.subtract(img, img/2, 'DType','double');
            validateattributes(out, {'double'}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_subtract(img, img/2, 'double');
                assert(isequal(out, expected));
            end

            out = cv.subtract(img, img/2, 'Mask',mask);
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_subtract(img, img/2, class(img), mask);
                assert(isequal(out, expected));
            end

            out = cv.subtract(img, img/2, ...
                'Dest',img, 'Mask',mask, 'DType',class(img));
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_subtract(img, img/2, class(img), mask, img);
                assert(isequal(out, expected));
            end
        end

        function test_2d_matrix
            A = uint8([100 150; 200 250]);
            B = uint8([200 100; 100 100]);
            mask = true(size(A));
            mask(4) = false;

            out = ones(size(A), 'uint8');
            out = cv.subtract(A, B, 'Mask',mask, 'Dest',out);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([0 50; 100 1]);
            assert(isequal(out, expected));

            out = cv.subtract(A, B, 'Mask',mask);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([0 50; 100 0]);
            assert(isequal(out, expected));

            out = cv.subtract(A, B);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = A - B;
            assert(isequal(out, expected));

            out = cv.subtract(A, 1);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = A - 1;
            assert(isequal(out, expected));

            out = cv.subtract(1, A);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = 1 - A;
            assert(isequal(out, expected));

            out = cv.subtract(2, 1);
            validateattributes(out, {'double'}, {'scalar'});
            expected = 2 - 1;
            assert(isequal(out, expected));
        end

        function test_output_depth
            out = cv.subtract(int16(100), uint8(200), 'DType','single');
            validateattributes(out, {'single'}, {'scalar'});
            assert(isequal(out, -100));
        end

        function test_saturation
            out = cv.subtract(uint8(100), uint8(200), 'DType','uint8');
            validateattributes(out, {'uint8'}, {'scalar'});
            assert(isequal(out, 0));

            out = cv.subtract(uint8(100), uint8(200), 'DType','int16');
            validateattributes(out, {'int16'}, {'scalar'});
            assert(isequal(out, -100));

            % saturation not applied for int32 (result overflows)
            out = cv.subtract(int32(1073741824), int32(-1073741824), 'DType','int32');
            %validateattributes(out, {'int32'}, {'scalar', '<',0});

            % unlike MATLAB where result saturates
            %out = int32(1073741824) - int32(-1073741824);
            %assert(isequal(out, intmax('int32')));
        end

        function test_error_argnum
            try
                cv.subtract();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_subtract(src1, src2, dtype, mask, dst)
    %MY_SUBTRACT  Similar to cv.subtract using imsubtract from IPT

    if nargin < 3, dtype = class(src1); end
    if nargin < 4, mask = true(size(src1,1),size(src1,2)); end
    if nargin < 5, dst = zeros(size(src1), dtype); end

    % subtract two images with specified output class
    out = imsubtract(src1, src2);
    out = cast(out, dtype);

    % apply masking
    if ~isempty(mask)
        for k=1:size(out,3)
            out_slice = out(:,:,k);
            dst_slice = dst(:,:,k);
            out_slice(~mask) = dst_slice(~mask);
            out(:,:,k) = out_slice;
        end
    end
end

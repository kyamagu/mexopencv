classdef TestBitwiseOr
    %TestBitwiseOr

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_rgb_images
            img1 = cv.imread(TestBitwiseOr.im, 'ReduceScale',2);
            img2 = cv.cvtColor(img1, 'RGB2HSV');

            % rectangular mask
            [h,w,~] = size(img1);
            mask = false([h w]);
            mask(100:h-100,100:w-100) = true;

            out = cv.bitwise_or(img1, img2);
            validateattributes(out, {class(img1)}, {'size',size(img1)});
            expected = my_bitwise_or(img1, img2);
            assert(isequal(out, expected));

            out = cv.bitwise_or(img1, img2, 'Mask',mask);
            validateattributes(out, {class(img1)}, {'size',size(img1)});
            expected = my_bitwise_or(img1, img2, mask);
            assert(isequal(out, expected));

            out = cv.bitwise_or(img1, img2, 'Mask',mask, 'Dest',img1);
            validateattributes(out, {class(img1)}, {'size',size(img1)});
            expected = my_bitwise_or(img1, img2, mask, img1);
            assert(isequal(out, expected));
        end

        function test_float_images
            img1 = cv.imread(TestBitwiseOr.im, 'ReduceScale',2);
            img1 = single(img1) ./ 255;
            img2 = cv.cvtColor(img1, 'RGB2HSV');
            img2(:,:,1) = img2(:,:,1) ./ 360;

            % circular mask
            [h,w,~] = size(img1);
            [X,Y] = meshgrid(1:w,1:h);
            c = fix([w h]/2); r = 50;
            mask = ((X-c(1)).^2 + (Y-c(2)).^2) < r^2;

            out = cv.bitwise_or(img1, img2);
            validateattributes(out, {class(img1)}, {'size',size(img1)});
            expected = my_bitwise_or(img1, img2);
            assert(isequaln(out, expected));

            out = cv.bitwise_or(img1, img2, 'Mask',mask);
            validateattributes(out, {class(img1)}, {'size',size(img1)});
            expected = my_bitwise_or(img1, img2, mask);
            assert(isequaln(out, expected));

            out = cv.bitwise_or(img1, img2, 'Mask',mask, 'Dest',img1);
            validateattributes(out, {class(img1)}, {'size',size(img1)});
            expected = my_bitwise_or(img1, img2, mask, img1);
            assert(isequaln(out, expected));
        end

        function test_vectors
            A = uint8([250 253 0]);
            B = uint8([1 2 255]);
            mask = [true false true];

            % uint8([251 255 255])
            out = cv.bitwise_or(A, B);
            validateattributes(out, {class(A)}, {'size',size(A)});
            expected = bitor(A, B);
            assert(isequal(out, expected));

            % uint8([251 0 255])
            out = cv.bitwise_or(A, B, 'Mask',mask);
            validateattributes(out, {class(A)}, {'size',size(A)});
            expected = bitor(A, B);
            expected(~mask) = 0;
            assert(isequal(out, expected));

            % uint8([251 253 255])
            out = cv.bitwise_or(A, B, 'Mask',mask, 'Dest',A);
            validateattributes(out, {class(A)}, {'size',size(A)});
            expected = bitor(A, B);
            expected(~mask) = A(~mask);
            assert(isequal(out, expected));
        end

        function test_error_argnum
            try
                cv.bitwise_or();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_bitwise_or(src1, src2, mask, dst)
    %MY_BITWISE_OR  Similar to cv.bitwise_or using core MATLAB functions

    if nargin < 3, mask = true(size(src1,1), size(src1,2)); end
    if nargin < 4, dst = zeros(size(src1), class(src1)); end

    % calculate bitwise OR
    if isinteger(src1)
        out = bitor(src1, src2);
    elseif isfloat(src1)
        if isa(src1, 'double')
            klass = 'uint64';
        elseif isa(src1, 'single')
            klass = 'uint32';
        end
        out = bitor(typecast(src1(:), klass), typecast(src2(:), klass));
        out = reshape(typecast(out, class(src1)), size(src1));
    end

    % apply masking
    for k=1:size(out,3)
        out_slice = out(:,:,k);
        dst_slice = dst(:,:,k);
        out_slice(~mask) = dst_slice(~mask);
        out(:,:,k) = out_slice;
    end
end

classdef TestBitwiseNot
    %TestBitwiseNot

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_rgb_image
            img = cv.imread(TestBitwiseNot.im, 'ReduceScale',2);

            % rectangular mask
            [h,w,~] = size(img);
            mask = false([h w]);
            mask(100:h-100,100:w-100) = true;

            out = cv.bitwise_not(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
            expected = my_bitwise_not(img);
            assert(isequal(out, expected));

            out = cv.bitwise_not(img, 'Mask',mask);
            validateattributes(out, {class(img)}, {'size',size(img)});
            expected = my_bitwise_not(img, mask);
            assert(isequal(out, expected));

            out = cv.bitwise_not(img, 'Mask',mask, 'Dest',img);
            validateattributes(out, {class(img)}, {'size',size(img)});
            expected = my_bitwise_not(img, mask, img);
            assert(isequal(out, expected));
        end

        function test_float_image
            img = cv.imread(TestBitwiseNot.im, 'ReduceScale',2);
            img = single(img) ./ 255;

            % circular mask
            [h,w,~] = size(img);
            [X,Y] = meshgrid(1:w,1:h);
            c = fix([w h]/2); r = 50;
            mask = ((X-c(1)).^2 + (Y-c(2)).^2) < r^2;

            out = cv.bitwise_not(img);
            validateattributes(out, {class(img)}, {'size',size(img)});
            expected = my_bitwise_not(img);
            assert(isequaln(out, expected));

            out = cv.bitwise_not(img, 'Mask',mask);
            validateattributes(out, {class(img)}, {'size',size(img)});
            expected = my_bitwise_not(img, mask);
            assert(isequaln(out, expected));

            out = cv.bitwise_not(img, 'Mask',mask, 'Dest',img);
            validateattributes(out, {class(img)}, {'size',size(img)});
            expected = my_bitwise_not(img, mask, img);
            assert(isequaln(out, expected));
        end

        function test_vector
            src = uint8([1 2 3]);
            mask = [true false true];

            % uint8([254 253 252])
            out = cv.bitwise_not(src);
            validateattributes(out, {class(src)}, {'size',size(src)});
            expected = bitcmp(src);
            assert(isequal(out, expected));

            % uint8([254 0 252])
            out = cv.bitwise_not(src, 'Mask',mask);
            validateattributes(out, {class(src)}, {'size',size(src)});
            expected = bitcmp(src);
            expected(~mask) = 0;
            assert(isequal(out, expected));

            % uint8([254 2 252])
            out = cv.bitwise_not(src, 'Mask',mask, 'Dest',src);
            validateattributes(out, {class(src)}, {'size',size(src)});
            expected = bitcmp(src);
            expected(~mask) = src(~mask);
            assert(isequal(out, expected));
        end

        function test_error_argnum
            try
                cv.bitwise_not();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_bitwise_not(src, mask, dst)
    %MY_BITWISE_NOT  Similar to cv.bitwise_not using core MATLAB functions

    if nargin < 2, mask = true(size(src,1), size(src,2)); end
    if nargin < 3, dst = zeros(size(src), class(src)); end

    % calculate bitwise NOT
    if isinteger(src)
        out = bitcmp(src);
    elseif isfloat(src)
        if isa(src, 'double')
            klass = 'uint64';
        elseif isa(src, 'single')
            klass = 'uint32';
        end
        out = bitcmp(typecast(src(:), klass));
        out = reshape(typecast(out, class(src)), size(src));
    end

    % apply masking
    for k=1:size(out,3)
        out_slice = out(:,:,k);
        dst_slice = dst(:,:,k);
        out_slice(~mask) = dst_slice(~mask);
        out(:,:,k) = out_slice;
    end
end

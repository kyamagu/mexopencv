classdef TestAdd
    %TestAdd

    methods (Static)
        function test_rgb_image
            img = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'ReduceScale',2);
            [h,w,~] = size(img);
            mask = false(h,w);
            mask(100:h-100,100:w-100) = true;

            out = cv.add(img, img);
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_add(img, img);
                assert(isequal(out, expected));
            end

            out = cv.add(img, img, 'DType','double');
            validateattributes(out, {'double'}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_add(img, img, 'double');
                assert(isequal(out, expected));
            end

            out = cv.add(img, img, 'Mask',mask);
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_add(img, img, class(img), mask);
                assert(isequal(out, expected));
            end

            out = cv.add(img, img, ...
                'Dest',img, 'Mask',mask, 'DType',class(img));
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_add(img, img, class(img), mask, img);
                assert(isequal(out, expected));
            end
        end

        function test_2d_matrix
            M = uint8([100 150; 200 250]);
            mask = true(size(M));
            mask(4) = false;

            out = ones(size(M), 'uint8');
            out = cv.add(M, M, 'Mask',mask, 'Dest',out);
            validateattributes(out, {'uint8'}, {'size',size(M)});
            expected = uint8([200 255; 255 1]);
            assert(isequal(out, expected));

            out = cv.add(M, M, 'Mask',mask);
            validateattributes(out, {'uint8'}, {'size',size(M)});
            expected = uint8([200 255; 255 0]);
            assert(isequal(out, expected));

            out = cv.add(M, M);
            validateattributes(out, {'uint8'}, {'size',size(M)});
            expected = M + M;
            assert(isequal(out, expected));

            out = cv.add(M, 1);
            validateattributes(out, {'uint8'}, {'size',size(M)});
            expected = M + 1;
            assert(isequal(out, expected));

            out = cv.add(1, M);
            validateattributes(out, {'uint8'}, {'size',size(M)});
            expected = 1 + M;
            assert(isequal(out, expected));

            out = cv.add(1, 1);
            validateattributes(out, {'double'}, {'scalar'});
            expected = 1 + 1;
            assert(isequal(out, expected));
        end

        function test_output_depth
            out = cv.add(uint16(1), int8(1), 'DType','single');
            validateattributes(out, {'single'}, {'scalar'});
            assert(isequal(out, 2));
        end

        function test_saturation
            out = cv.add(uint8(200), uint8(200), 'DType','uint8');
            validateattributes(out, {'uint8'}, {'scalar'});
            assert(isequal(out, 255));

            out = cv.add(uint8(200), uint8(200), 'DType','uint16');
            validateattributes(out, {'uint16'}, {'scalar'});
            assert(isequal(out, 400));

            % saturation not applied for int32 (result overflows)
            out = cv.add(int32(1073741824), int32(1073741824), 'DType','int32');
            %validateattributes(out, {'int32'}, {'scalar', '<',0});

            % unlike MATLAB where result saturates
            %out = int32(1073741824) + int32(1073741824);
            %assert(isequal(out, intmax('int32')));
        end

        function test_error_argnum
            try
                cv.add();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_add(src1, src2, dtype, mask, dst)
    %MY_ADD  Similar to cv.add using imadd from IPT

    if nargin < 3, dtype = class(src1); end
    if nargin < 4, mask = true(size(src1,1),size(src1,2)); end
    if nargin < 5, dst = zeros(size(src1), dtype); end

    % add two images with specified output class
    out = imadd(src1, src2, dtype);

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

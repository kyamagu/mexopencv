classdef TestAddWeighted
    %TestAddWeighted

    methods (Static)
        function test_images
            img1 = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'ReduceScale',2);
            img2 = randi([0 255], size(img1), 'uint8');

            out = cv.addWeighted(img1,1.0, img2,0.4, 0.2);
            validateattributes(out, {class(img1)}, {'size',size(img1)});
            if mexopencv.require('images')
                expected = my_add_weighted(img1,1.0, img2,0.4, 0.2);
                assert(isequal(out, expected));
            end
        end

        function test_2d_matrices
            A = uint8([100 150; 200 250]);
            B = uint8([200 100; 100 100]);

            out = cv.addWeighted(A,0.2, B,0.8, 0.0);
            validateattributes(out, {class(A)}, {'size',size(A)});
            expected = A*0.2 + B*0.8 + 0;
            assert(isequal(out, expected));

            out = cv.addWeighted(A,0.2, 1,0.8, 0.0);
            validateattributes(out, {class(A)}, {'size',size(A)});
            expected = A*0.2 + 1*0.8 + 0;
            assert(isequal(out, expected));

            out = cv.addWeighted(1,0.2, B,0.8, 0.0);
            validateattributes(out, {class(B)}, {'size',size(B)});
            expected = 1*0.2 + B*0.8 + 0;
            assert(isequal(out, expected));

            out = cv.addWeighted(1,0.2, 1,0.8, 0.0);
            validateattributes(out, {'double'}, {'scalar'});
            expected = 1*0.2 + 1*0.8 + 0;
            assert(isequal(out, expected));
        end

        function test_output_depth
            out = cv.addWeighted(uint16(1),0.5, int8(1),0.5, 0.0, 'DType','single');
            validateattributes(out, {'single'}, {'scalar'});
            expected = single(1*0.5 + 1*0.5 + 0);
            assert(isequal(out, expected));
        end

        function test_error_argnum
            try
                cv.addWeighted();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_add_weighted(src1, a, src2, b, c, dtype)
    %MY_ADD_WEIGHTED  Similar to cv.addWeighted using imlincomb from IPT

    if nargin < 6, dtype = class(src1); end

    % add two weighted images with specified output class
    out = imlincomb(a,src1, b,src2, c, dtype);
end

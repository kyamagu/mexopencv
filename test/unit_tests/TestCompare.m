classdef TestCompare
    %TestCompare

    methods (Static)
        function test_rgb_image
            img = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'ReduceScale',2);

            out = cv.compare(img, img, 'eq');
            validateattributes(out, {'uint8'}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_compare(img, img, 'eq');
                assert(isequal(out, expected));
            end
        end

        function test_2d_matrix
            A = uint8([100 150; 200 100]);
            B = uint8([200 100; 100 100]);

            op = {'eq', 'ne', 'gt', 'ge', 'lt', 'le'};
            for i=1:numel(op)
                out = cv.compare(A, B, op{i});
                validateattributes(out, {'uint8'}, {'size',size(A)});
                expected = my_compare(A, B, op{i});
                assert(isequal(out, expected));
            end

            out = cv.compare(A, 150, 'gt');
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = my_compare(A, 150, 'gt');
            assert(isequal(out, expected));

            out = cv.compare(150, A, 'ge');
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = my_compare(150, A, 'ge');
            assert(isequal(out, expected));

            out = cv.compare(150, 150, 'ne');
            validateattributes(out, {'uint8'}, {'scalar'});
            expected = my_compare(150, 150, 'ne');
            assert(isequal(out, expected));
        end

        function test_error_argnum
            try
                cv.compare();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_compare(src1, src2, op)
    %MY_COMPARE  Similar to cv.compare

    % compare two images
    switch lower(op)
        case 'eq'
            out = (src1 == src2);
        case 'ne'
            out = (src1 ~= src2);
        case 'lt'
            out = (src1 < src2);
        case 'le'
            out = (src1 <= src2);
        case 'gt'
            out = (src1 > src2);
        case 'ge'
            out = (src1 >= src2);
        otherwise
            error('Unrecognized operation')
    end
    out = uint8(out * 255);
end

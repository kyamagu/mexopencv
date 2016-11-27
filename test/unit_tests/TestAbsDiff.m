classdef TestAbsDiff
    %TestAbsDiff

    methods (Static)
        function test_rgb_image
            img = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), 'ReduceScale',2);

            out = cv.absdiff(img/2, img);
            validateattributes(out, {class(img)}, {'size',size(img)});
            if mexopencv.require('images')
                expected = my_absdiff(img/2, img);
                assert(isequal(out, expected));
            end
        end

        function test_2d_matrix
            A = uint8([100 150; 200 100]);
            B = uint8([200 100; 100 250]);

            out = cv.absdiff(A, B);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([100 50; 100 150]);
            assert(isequal(out, expected));

            out = cv.absdiff(A, 150);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([50 0; 50 50]);
            assert(isequal(out, expected));

            out = cv.absdiff(150, A);
            validateattributes(out, {'uint8'}, {'size',size(A)});
            expected = uint8([50 0; 50 50]);
            assert(isequal(out, expected));

            out = cv.absdiff(100, 150);
            validateattributes(out, {'double'}, {'scalar'});
            expected = abs(100 - 150);
            assert(isequal(out, expected));
        end

        function test_saturation
            out = cv.absdiff(int8(100), int8(100));
            validateattributes(out, {'int8'}, {'scalar'});
            assert(isequal(out, 0));

            out = cv.absdiff(int8(100), int8(-100));
            validateattributes(out, {'int8'}, {'scalar'});
            assert(isequal(out, 127));

            % saturation not applied for int32 (result overflows)
            out = cv.absdiff(int32(1073741824), int32(-1073741824));
            %validateattributes(out, {'int32'}, {'scalar', '<',0});

            % unlike MATLAB where result saturates
            %out = abs(int32(1073741824) - int32(-1073741824));
            %assert(isequal(out, intmax('int32')));
        end

        function test_error_argnum
            try
                cv.absdiff();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function out = my_absdiff(src1, src2)
    %MY_ABSDIFF  Similar to cv.absdiff using imabsdiff from IPT

    % absolute difference of two images
    out = imabsdiff(src1, src2);
end

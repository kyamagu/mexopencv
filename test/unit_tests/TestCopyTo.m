classdef TestCopyTo
    %TestCopyTo

    methods (Static)
        function test_1
            A = magic(5);
            B = cv.copyTo(A);
            validateattributes(B, {class(A)}, {'size',size(A)});
            assert(isequal(B, A));
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            [h,w,~] = size(img);
            mask = false(h,w);
            mask(:,1:fix(w/2)) = true;  % only copy left half

            dst = cv.copyTo(img, 'Mask',mask);
            validateattributes(dst, {class(img)}, {'size',size(img)});

            dst = randi([0 255], size(img), class(img));
            dst = cv.copyTo(img, 'Mask',mask, 'Dest',dst);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.copyTo();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

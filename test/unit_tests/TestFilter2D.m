classdef TestFilter2D
    %TestFilter2D

    methods (Static)
        function test_1
            A = magic(7);
            kernel = [0 0 1; 1 1 1; 1 1 1];
            reference = filter2(kernel, A, 'same');
            result = cv.filter2D(A, kernel, 'BorderType','Constant');
            assert(isequal(reference,result));
            validateattributes(result, {class(A)}, {'size',size(A)});
        end

        function test_2
            A = magic(7);
            kernel = [0 0 1; 1 1 1];
            reference = filter2(kernel, A, 'same');
            result = cv.filter2D(A, kernel, 'BorderType','Constant', ...
                'Anchor',fliplr(floor((size(kernel)-1)/2)));
            assert(isequal(reference,result));
            validateattributes(result, {class(A)}, {'size',size(A)});
        end

        function test_3
            A = magic(7);
            kernel = [1 1 1];
            reference = filter2(kernel, A, 'same');
            result = cv.filter2D(A, kernel, 'BorderType','Constant');
            assert(isequal(reference,result));
            validateattributes(result, {class(A)}, {'size',size(A)});
        end

        function test_4
            A = magic(7);
            kernel = 1;
            reference = filter2(kernel, A, 'same');
            result = cv.filter2D(A, kernel, 'BorderType','Constant');
            assert(isequal(reference,result));
            validateattributes(result, {class(A)}, {'size',size(A)});
        end

        function test_5
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            result = cv.filter2D(img, ones(3)./9);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_options
            A = uint8(magic(10));
            kernel = (rand(4) > 0.5);
            result = cv.filter2D(A, kernel, 'DDepth','single', ...
                'Anchor',[-1 -1], 'Delta',0, 'BorderType','Default');
            validateattributes(result, {'single'}, {'size',size(A)});
        end

        function test_large_kernel
            A = randn(500);
            kernel = (rand(15) > 0.5);
            result = cv.filter2D(A, kernel);
            validateattributes(result, {class(A)}, {'size',size(A)});
        end

        function test_error_1
            try
                cv.filter2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

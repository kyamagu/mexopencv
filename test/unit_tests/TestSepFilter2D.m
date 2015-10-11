classdef TestSepFilter2D
    %TestSepFilter2D

    methods (Static)
        function test_1
            A = magic(7);
            kernel = [1 2 1];
            reference = filter2(kernel.', filter2(kernel, A, 'same'), 'same');
            result = cv.sepFilter2D(A, kernel, kernel, 'BorderType','Constant');
            assert(isequal(reference,result));
            validateattributes(result, {class(A)}, {'size',size(A)});
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
            result = cv.sepFilter2D(img, ones(1,7)./7, ones(1,7)./7);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_options
            A = uint8(magic(10));
            kernelX = (rand(1,4) > 0.5);
            kernelY = (rand(1,4) > 0.5);
            result = cv.sepFilter2D(A, kernelX, kernelY, 'DDepth','single', ...
                'Anchor',[-1 -1], 'Delta',0, 'BorderType','Default');
            validateattributes(result, {'single'}, {'size',size(A)});
        end

        function test_large_kernel
            A = randn(500);
            kernel = (rand(1,15) > 0.5);
            result = cv.sepFilter2D(A, kernel, kernel);
            validateattributes(result, {class(A)}, {'size',size(A)});
        end

        function test_error_1
            try
                cv.sepFilter2D();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

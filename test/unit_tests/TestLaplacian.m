classdef TestLaplacian
    %TestLaplacian

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','blox.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestLaplacian.im);
            result = cv.Laplacian(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestLaplacian.im);
            result = cv.Laplacian(img, 'KSize',5);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_3
            img = imread(TestLaplacian.im);
            result = cv.Laplacian(img, 'DDepth',-1, ...
                'KSize',1, 'Scale',1, 'Delta',0, 'BorderType','Default');
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.Laplacian();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

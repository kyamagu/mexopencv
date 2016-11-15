classdef TestGaussianBlur
    %TestGaussianBlur

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','blox.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestGaussianBlur.im);
            result = cv.GaussianBlur(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestGaussianBlur.im);
            result = cv.GaussianBlur(img, 'KSize',[5 7]);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_3
            img = imread(TestGaussianBlur.im);
            result = cv.GaussianBlur(img, 'KSize',[5 7], ...
                'SigmaX',1.1, 'SigmaY',1.3, 'BorderType','Default');
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.GaussianBlur();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

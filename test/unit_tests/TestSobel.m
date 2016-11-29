classdef TestSobel
    %TestSobel

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','blox.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestSobel.im);
            result = cv.Sobel(img);
            validateattributes(result, {class(img)}, {'size',size(img)});
        end

        function test_2
            img = imread(TestSobel.im);
            result = cv.Sobel(img, 'KSize',5, ...
                'XOrder',0, 'YOrder',1, 'Scale',1, 'Delta',0, ...
                'BorderType','Default', 'DDepth','double');
            validateattributes(result, {'double'}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.Sobel();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

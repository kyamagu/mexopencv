classdef TestBalanceWhite
    %TestBalanceWhite
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','lena.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestBalanceWhite.im);
            dst = cv.balanceWhite(img, 'Type','Simple', ...
                'InputMin',0, 'InputMax',255, 'OutputMin',0, 'OutputMax',255);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_rgb
            % CV_8UC3
            img = imread(TestBalanceWhite.im);
            dst = cv.balanceWhite(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});

            % CV_32FC3
            img = single(img) / 255;
            dst = cv.balanceWhite(img, 'InputMax',1, 'OutputMax',1);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_gray
            % CV_8U
            img = cv.imread(TestBalanceWhite.im, 'Grayscale',true);
            dst = cv.balanceWhite(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});

            % CV_32F
            img = single(img) / 255;
            dst = cv.balanceWhite(img, 'InputMax',1, 'OutputMax',1);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_error_1
            try
                cv.balanceWhite();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end

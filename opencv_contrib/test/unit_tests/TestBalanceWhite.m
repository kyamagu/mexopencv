classdef TestBalanceWhite
    %TestBalanceWhite
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
    end

    methods (Static)
        function test_1
            dst = cv.balanceWhite(TestBalanceWhite.im, 'Type','Simple', ...
                'InputMin',0, 'InputMax',255, 'OutputMin',0, 'OutputMax',255);
            validateattributes(dst, {class(TestBalanceWhite.im)}, ...
                {'size',size(TestBalanceWhite.im)});
        end

        function test_rgb
            % CV_8UC3
            img = TestBalanceWhite.im;
            dst = cv.balanceWhite(img);
            validateattributes(dst, {class(img)}, {'size',size(img)});

            % CV_32FC3
            img = single(img) / 255;
            dst = cv.balanceWhite(img, 'InputMax',1, 'OutputMax',1);
            validateattributes(dst, {class(img)}, {'size',size(img)});
        end

        function test_gray
            % CV_8U
            img = rgb2gray(TestBalanceWhite.im);
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

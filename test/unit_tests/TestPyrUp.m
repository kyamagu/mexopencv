classdef TestPyrUp
    %TestPyrUp

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_uint8_img
            img = imread(TestPyrUp.im);
            result = cv.pyrUp(img);
        end

        function test_double_img
            img = imread(TestPyrUp.im);
            img = double(img) ./ 255;
            result = cv.pyrUp(img);
        end

        function test_custom_size
            img = imread(TestPyrUp.im);
            img = img(1:400,1:512,:);
            [h,w,~] = size(img);
            sz = [w,h].*2;
            result = cv.pyrUp(img, 'DstSize',sz);
        end

        function test_error_argnum
            try
                cv.pyrUp();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

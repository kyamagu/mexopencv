classdef TestPyrUp
    %TestPyrUp

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_uint8_img
            img = cv.imread(TestPyrUp.im, 'ReduceScale',2);
            result = cv.pyrUp(img);
        end

        function test_double_img
            img = cv.imread(TestPyrUp.im, 'ReduceScale',2);
            img = double(img) ./ 255;
            result = cv.pyrUp(img);
        end

        function test_custom_size
            img = cv.imread(TestPyrUp.im, 'ReduceScale',2);
            img = img(1:200,1:256,:);
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

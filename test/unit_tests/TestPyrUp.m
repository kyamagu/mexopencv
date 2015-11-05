classdef TestPyrUp
    %TestPyrUp
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestPyrUp.im);
            result = cv.pyrUp(img);
        end

        function test_2
            img = imread(TestPyrUp.im);
            img = double(img) ./ 255;
            result = cv.pyrUp(img);
        end

        function test_3
            img = imread(TestPyrUp.im);
            img = img(1:400,1:512);
            [h,w,~] = size(img);
            sz = [w,h].*2;
            result = cv.pyrUp(img, 'DstSize',sz);
        end

        function test_error_1
            try
                cv.pyrUp();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

classdef TestPyrUp
    %TestPyrUp
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_1
            result = cv.pyrUp(TestPyrUp.im);
        end

        function test_2
            img = double(TestPyrUp.im) ./ 255;
            result = cv.pyrUp(img);
        end

        function test_3
            img = TestPyrUp.im;
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

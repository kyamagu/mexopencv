classdef TestPyrDown
    %TestPyrDown
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestPyrDown.im);
            result = cv.pyrDown(img);
        end

        function test_2
            img = imread(TestPyrDown.im);
            img = double(img) ./ 255;
            result = cv.pyrDown(img);
        end

        function test_3
            img = imread(TestPyrDown.im);
            img = img(1:400,1:512);
            [h,w,~] = size(img);
            sz = round([w,h]./2);
            result = cv.pyrDown(img, 'DstSize',sz);
        end

        function test_4
            img = imread(TestPyrDown.im);
            img2 = cv.pyrDown(img);
            img3 = cv.pyrDown(img2);
            img4 = cv.pyrDown(img3);
            imgP = cv.buildPyramid(img, 'MaxLevel',3);
            assert(isequal(imgP{1},img))
            assert(isequal(imgP{2},img2))
            assert(isequal(imgP{3},img3))
            assert(isequal(imgP{4},img4))
        end

        function test_error_1
            try
                cv.pyrDown();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

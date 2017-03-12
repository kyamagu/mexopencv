classdef TestPyrDown
    %TestPyrDown

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_uint8_img
            img = imread(TestPyrDown.im);
            result = cv.pyrDown(img);
        end

        function test_double_img
            img = imread(TestPyrDown.im);
            img = double(img) ./ 255;
            result = cv.pyrDown(img);
        end

        function test_custom_size
            img = imread(TestPyrDown.im);
            img = img(1:400,1:512,:);
            [h,w,~] = size(img);
            sz = round([w,h]./2);
            result = cv.pyrDown(img, 'DstSize',sz);
        end

        function test_pyramid
            img = imread(TestPyrDown.im);
            mxLvl = 3;
            imgD = cell(1,mxLvl+1);
            imgD{1} = img;
            for i=2:mxLvl+1
                imgD{i} = cv.pyrDown(imgD{i-1});
            end
            imgP = cv.buildPyramid(img, 'MaxLevel',mxLvl);
            assert(isequal(imgP(:), imgD(:)));
        end

        function test_error_argnum
            try
                cv.pyrDown();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

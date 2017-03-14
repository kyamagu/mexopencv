classdef TestCanny2
    %TestCanny2

    methods (Static)
        function test_canny_custom_gradient
            img = cv.imread(fullfile(mexopencv.root(),'test','img001.jpg'), ...
                'Grayscale',true, 'ReduceScale',2);
            dx = cv.Sobel(img, 'XOrder',1, 'YOrder',0, 'KSize',5);
            dy = cv.Sobel(img, 'XOrder',0, 'YOrder',1, 'KSize',5);
            result = cv.Canny2(dx, dy, [96,192], 'L2Gradient',true);
            [h,w,~] = size(img);
            validateattributes(result, {class(img)}, {'2d', 'size',[h,w]});
        end

        function test_error_argnum
            try
                cv.Canny2();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
